import 'dart:io';
import 'package:chatify/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// A form bloc that handles group creation functionality.
///
/// This class manages:
/// - Input validation for group name and participants.
/// - Adding/removing participants with duplicate and empty checks.
/// - Storing group data in Firestore.
/// - Uploading group image to Firebase Storage.
/// - Subscribing users to notification topics for the created group.
class GroupCreationFormBloc extends FormBloc<String, String> {
  /// The selected image file for the group.
  File? selectedImage;

  /// Bloc for the group name input field.
  ///
  /// Validators:
  /// - `required`: Ensures the group name is not empty.
  final groupName = TextFieldBloc(validators: [FieldBlocValidators.required]);

  /// Bloc for managing the list of participants in the group.
  ///
  /// Each participant is represented as a `TextFieldBloc`.
  final participants = ListFieldBloc<TextFieldBloc, dynamic>(name: 'participants');

  /// ID of the user creating the group.
  final String creatorID = FirebaseAuth.instance.currentUser!.uid;

  /// Constructor for `GroupCreationFormBloc`.
  ///
  /// Initializes the bloc and adds field blocs for `groupName` and `participants`.
  GroupCreationFormBloc() {
    addFieldBlocs(fieldBlocs: [groupName, participants]);
    debugPrint("GroupCreationFormBloc initialized for user ID: $creatorID");
  }

  /// Adds an empty participant field to the participants list.
  void addParticipant() {
    participants.addFieldBloc(TextFieldBloc(validators: [FieldBlocValidators.required]));
    debugPrint("Added empty participant field");
  }

  /// Adds a participant with the provided name to the participants list.
  ///
  /// Ensures that duplicate names are not added.
  void addParticipantWithName(String participantName) {
    if (!isDuplicateParticipant(participantName)) {
      participants.addFieldBloc(
        TextFieldBloc(initialValue: participantName, validators: [FieldBlocValidators.required]),
      );
      debugPrint("Added participant with name: $participantName");
    }
  }

  /// Checks if the given participant name is already in the participants list.
  bool isDuplicateParticipant(String participant) {
    final isDuplicate = participants.value.any(
      (p) => p.value.trim().toLowerCase() == participant.trim().toLowerCase(),
    );
    debugPrint("Checked for duplicate participant '$participant': $isDuplicate");
    return isDuplicate;
  }

  /// Checks if the participants list contains any duplicate names.
  bool hasDuplicateParticipants() {
    final participantNames = participants.value.map((p) => p.value.trim().toLowerCase()).toList();
    final isDuplicate = participantNames.length != participantNames.toSet().length;
    debugPrint("Checked for any duplicate participants: $isDuplicate");
    return isDuplicate;
  }

  /// Checks if any participant fields in the participants list are empty.
  bool hasEmptyParticipantFields() {
    final hasEmpty = participants.value.any((p) => p.value.trim().isEmpty);
    debugPrint("Checked for empty participant fields: $hasEmpty");
    return hasEmpty;
  }

  /// Removes a participant from the participants list at the given index.
  void removeParticipant(int index) {
    participants.removeFieldBlocAt(index);
    debugPrint("Removed participant at index: $index");
  }

  /// Initializes the form with data from an existing group.
  ///
  /// Loads the group name and participants from Firestore.
  Future<void> initializeForm(String groupId) async {
    try {
      debugPrint("Initializing form with group ID: $groupId");
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        debugPrint("Group with ID: $groupId does not exist");
        return;
      }

      final groupData = groupDoc.data();
      groupName.updateInitialValue(groupData?['name'] ?? '');
      debugPrint("Group name set to: ${groupName.value}");

      final participantIds = List<String>.from(groupData?['participants'] ?? []);
      for (final userId in participantIds.where((id) => id != creatorID)) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final username = userDoc['username'] ?? 'Unknown User';
        addParticipantWithName(username);
      }
    } catch (e) {
      debugPrint("Error initializing form: $e");
      emitFailure(failureResponse: 'Error loading group data');
    }
  }

  /// Handles the form submission process for creating a group.
  ///
  /// This method:
  /// - Validates the form for duplicate and empty participants.
  /// - Verifies participant names exist in the database.
  /// - Uploads the group image to Firebase Storage.
  /// - Saves the group information to Firestore.
  /// - Subscribes participants to the notification topic for the group.
  @override
  Future<void> onSubmitting() async {
    debugPrint("Form submission started by user ID: $creatorID");
    try {
      if (hasDuplicateParticipants()) {
        debugPrint("Submission failed: Duplicate participants found");
        emitFailure(
          failureResponse: 'Duplicate participants found. Please ensure all participant names are unique.',
        );
        return;
      }

      if (hasEmptyParticipantFields()) {
        debugPrint("Submission failed: Empty participant fields detected");
        emitFailure(
          failureResponse: 'Please fill in all participant fields or remove any empty fields.',
        );
        return;
      }

      List<String> verifiedParticipantIds = [creatorID];
      for (final participant in participants.value) {
        final participantName = participant.value.trim();
        debugPrint("Verifying participant name: $participantName");

        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: participantName)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final participantId = userQuery.docs.first.id;
          verifiedParticipantIds.add(participantId);
          debugPrint("Verified participant ID for $participantName: $participantId");
        } else {
          debugPrint("User $participantName does not exist");
          emitFailure(failureResponse: 'User $participantName does not exist');
          return;
        }
      }

      if (selectedImage == null) {
        debugPrint("Submission failed: No group image selected");
        emitFailure(failureResponse: 'Please add a group image.');
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('group_images')
          .child('${groupName.value}_${DateTime.now().microsecondsSinceEpoch}.jpg');
      await storageRef.putFile(selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();
      debugPrint("Uploaded group image to: $imageUrl");

      final groupDocRef = await FirebaseFirestore.instance.collection('groups').add({
        'name': groupName.value,
        'groupImageUrl': imageUrl,
        'participants': verifiedParticipantIds,
        'creatorId': creatorID,
        'lastMessage': '',
        'lastMessageTimestamp': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });
      debugPrint("Group document created with ID: ${groupDocRef.id}");

      // Subscribe to the group topic using NotificationService.
      NotificationService().subscribeToTopic(groupDocRef.id);

      emitSuccess(successResponse: 'Group created successfully');
    } catch (error) {
      debugPrint("Failed to create group: $error");
      emitFailure(failureResponse: 'Failed to create group');
    }
  }
}

/// Deletes a group from Firestore.
///
/// This function verifies if the current user is the creator of the group,
/// deletes associated image from Firebase Storage, and unsubscribes from the group's notification topic.
Future<void> deleteGroup(BuildContext context, String groupId) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to delete a group.")),
      );
    }
    return;
  }

  try {
    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group does not exist.")),
        );
      }
      return;
    }

    final groupData = groupDoc.data();
    final creatorId = groupData?['creatorId'];

    if (creatorId != currentUser.uid) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Only the creator can delete this group.")),
        );
      }
      return;
    }

    final imageUrl = groupData?['groupImageUrl'] as String?;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    }

    await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();

    // Unsubscribe from the group's notification topic.
    NotificationService().unsubscribeFromTopic(groupId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group deleted successfully")),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting group: $e")),
      );
    }
  }
}
