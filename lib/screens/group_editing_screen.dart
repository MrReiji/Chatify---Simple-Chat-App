import 'package:chatify/screens/chats_screen.dart';
import 'package:chatify/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatify/constants/constants.dart';
import 'package:chatify/design_widgets/buttons/primary_button.dart';
import 'package:chatify/design_widgets/fields/input_widget.dart';
import 'package:chatify/design_widgets/fields/user_image_picker.dart';
import 'package:chatify/blocs/chat/group_creation_form_bloc.dart';
import 'package:chatify/design_widgets/dialogs/loading_dialog.dart';

class GroupEditingScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImageUrl;

  const GroupEditingScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
  }) : super(key: key);

  @override
  _GroupEditingScreenState createState() => _GroupEditingScreenState();
}

class _GroupEditingScreenState extends State<GroupEditingScreen> {
  late GroupCreationFormBloc groupCreationFormBloc;
  bool isCreator = false;

  @override
  void initState() {
    super.initState();
    groupCreationFormBloc = GroupCreationFormBloc();
    _fetchInitialData();
    _subscribeToChatTopic(widget.groupId); // Subskrypcja na temat przy otwarciu ekranu
  }

  Future<void> _fetchInitialData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
    final creatorId = groupDoc['creatorId'];
    isCreator = currentUser?.uid == creatorId;

    groupCreationFormBloc.groupName.updateInitialValue(widget.groupName);

    final participantIds = List<String>.from(groupDoc['participants'] ?? []);
    final filteredIds = participantIds.where((id) => id != creatorId).toList();

    for (final userId in filteredIds) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final username = userDoc['username'] ?? 'Unknown User';
      groupCreationFormBloc.addParticipantWithName(username);
    }

    setState(() {});
  }

  Future<void> _subscribeToChatTopic(String groupId) async {
    NotificationService().subscribeToTopic('group_$groupId');
    debugPrint('Subscribed to topic: group_$groupId');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => groupCreationFormBloc,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Edit Group Chat"),
              backgroundColor: kPrimaryColor,
            ),
            body: FormBlocListener<GroupCreationFormBloc, String, String>(
              onSubmitting: (context, state) => LoadingDialog.show(context),
              onSubmissionFailed: (context, state) => LoadingDialog.hide(context),
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatsScreen(),
                  ),
                );
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failureResponse!)),
                );
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: kDefaultPadding),
                        Text(
                          "Edit Group",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                        const SizedBox(height: kDefaultPadding),

                        UserImagePicker(
                          onPickImage: (pickedImage) {
                            groupCreationFormBloc.selectedImage = pickedImage;
                          },
                          initialImageUrl: widget.groupImageUrl,
                        ),
                        const SizedBox(height: kDefaultPadding / 2),

                        InputWidget(
                          hintText: "Group Name",
                          prefixIcon: Icons.group,
                          fieldBloc: groupCreationFormBloc.groupName,
                        ),

                        BlocBuilder<ListFieldBloc<TextFieldBloc, dynamic>, ListFieldBlocState<TextFieldBloc, dynamic>>(
                          bloc: groupCreationFormBloc.participants,
                          builder: (context, state) {
                            return Column(
                              children: [
                                for (int i = 0; i < state.fieldBlocs.length; i++)
                                  InputWidget(
                                    hintText: "Participant ${i + 1}",
                                    prefixIcon: Icons.person,
                                    suffixIcon: Icons.cancel,
                                    onSuffixIconPressed: () {
                                      groupCreationFormBloc.removeParticipant(i);
                                    },
                                    fieldBloc: state.fieldBlocs[i],
                                  ),
                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton.icon(
                                    onPressed: groupCreationFormBloc.addParticipant,
                                    icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                                    label: Text(
                                      "Add Another Participant",
                                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: kDefaultPadding),

                        if (isCreator)
                          PrimaryButton(
                            text: "Save Changes",
                            press: () async {
                              await _saveChanges();
                            },
                          )
                        else
                          PrimaryButton(
                            text: "Leave Group",
                            press: () => _leaveGroup(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveChanges() async {
  // Sprawdzenie, czy nazwa grupy nie jest pusta
  if (groupCreationFormBloc.groupName.value.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Group name cannot be empty")),
    );
    return;
  }

  // Sprawdzenie, czy pola uczestników nie są puste i czy nie ma zduplikowanych wartości
  final updatedParticipantNames = groupCreationFormBloc.participants.value.map((e) => e.value.trim()).toList();
  if (updatedParticipantNames.any((name) => name.isEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Each participant field must be filled in")),
    );
    return;
  }

  if (updatedParticipantNames.length != updatedParticipantNames.toSet().length) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Each participant must have a unique name")),
    );
    return;
  }

  // Sprawdzenie, czy użytkownicy istnieją
  List<String> verifiedParticipantIds = [];
  for (final participantName in updatedParticipantNames) {
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: participantName)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      verifiedParticipantIds.add(userQuery.docs.first.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User $participantName does not exist")),
      );
      return;
    }
  }

  // Pobierz dokument grupy z Firestore
  final groupDoc = FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
  String? imageUrl;

  // Upload nowego obrazka, jeśli został wybrany
  if (groupCreationFormBloc.selectedImage != null) {
    final storageRef = FirebaseStorage.instance.ref().child('group_images').child('${widget.groupId}.jpg');
    await storageRef.putFile(groupCreationFormBloc.selectedImage!);
    imageUrl = await storageRef.getDownloadURL();
  }

  // Aktualizacja danych w grupie
  await groupDoc.update({
    'name': groupCreationFormBloc.groupName.value,
    'participants': [FirebaseAuth.instance.currentUser!.uid, ...verifiedParticipantIds],
    if (imageUrl != null) 'groupImageUrl': imageUrl,
  });

  groupCreationFormBloc.emitSuccess(); // Emit success to trigger onSuccess
}



  Future<void> _leaveGroup() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final groupDoc = FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
    await groupDoc.update({
      'participants': FieldValue.arrayRemove([currentUser?.uid])
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You left the group")),
    );
    Navigator.pop(context);
  }
}
