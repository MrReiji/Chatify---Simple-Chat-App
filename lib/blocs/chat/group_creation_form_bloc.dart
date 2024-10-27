import 'dart:io';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Manages the logic and form state for creating a new group chat.
/// Handles field validations, Firebase image uploads, and group data submission to Firestore.
class GroupCreationFormBloc extends FormBloc<String, String> {
  /// File containing the group image selected by the user.
  File? selectedImage;

  /// Field for the group name, marked as required.
  final groupName = TextFieldBloc(validators: [FieldBlocValidators.required]);

  /// List of participants, each represented by a username or email in a text field.
  final participants = ListFieldBloc<TextFieldBloc, dynamic>(name: 'participants');

  /// ID of the group creator, obtained from the authenticated Firebase user.
  final String creatorID = FirebaseAuth.instance.currentUser!.uid;

  GroupCreationFormBloc() {
    addFieldBlocs(fieldBlocs: [groupName, participants]);
    addParticipant();
  }

  /// Adds a new participant field to the participants list.
  void addParticipant() {
    participants.addFieldBloc(TextFieldBloc(validators: [FieldBlocValidators.required]));
  }

  /// Removes a participant field at the specified index.
  void removeParticipant(int index) {
    participants.removeFieldBlocAt(index);
  }

  /// Submits the form data to Firestore and handles image uploads if applicable.
  /// This includes saving group data, image URL, and participant IDs to Firestore.
  @override
  Future<void> onSubmitting() async {
    try {
      String? imageUrl;
      if (selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('group_images')
            .child('${groupName.value}_${DateTime.now().microsecondsSinceEpoch}.jpg');
        await storageRef.putFile(selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      List<String> participantIds = [creatorID];
      for (final participant in participants.value) {
        String? userId;

        // Attempt to find user by username
        final usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: participant.value.trim())
            .limit(1)
            .get();

        if (usernameQuery.docs.isNotEmpty) {
          userId = usernameQuery.docs.first.id;
        } else {
          // If no user found by username, attempt to find by email
          final emailQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: participant.value.trim())
              .limit(1)
              .get();

          if (emailQuery.docs.isNotEmpty) {
            userId = emailQuery.docs.first.id;
          } else {
            emitFailure(failureResponse: 'User ${participant.value} not found');
            return;
          }
        }

        participantIds.add(userId);
      }

      await FirebaseFirestore.instance.collection('groups').add({
        'name': groupName.value,
        'groupImageUrl': imageUrl,
        'participants': participantIds,
        'creatorId': creatorID,
        'lastMessage': '',
        'lastMessageTimestamp': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });

      emitSuccess(successResponse: 'Group created successfully');
    } catch (error) {
      emitFailure(failureResponse: 'Failed to create group');
    }
  }
}
