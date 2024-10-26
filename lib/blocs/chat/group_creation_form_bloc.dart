import 'dart:io';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GroupCreationFormBloc extends FormBloc<String, String> {
  File? selectedImage;
  final groupName = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final participants = ListFieldBloc<TextFieldBloc, dynamic>(name: 'participants');

  GroupCreationFormBloc() {
    addFieldBlocs(fieldBlocs: [groupName, participants]);
    addParticipant(); // Add the first participant field by default
  }

  // Dodawanie nowego pola uczestnika
  void addParticipant() {
    participants.addFieldBloc(TextFieldBloc(
      validators: [FieldBlocValidators.required],
    ));
  }

  // Usuwanie konkretnego uczestnika
  void removeParticipant(int index) {
    participants.removeFieldBlocAt(index);
  }

  @override
  Future<void> onSubmitting() async {
    try {
      // Upload group image if exists
      String? imageUrl;
      if (selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('group_images')
            .child('${groupName.value}.jpg');
        await storageRef.putFile(selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Save group data to Firestore
      await FirebaseFirestore.instance.collection('groups').add({
        'name': groupName.value,
        'groupImageUrl': imageUrl,
        'participants': participants.value.map((field) => field.value).toList(),
        'lastMessage': '',
        'time': DateTime.now().toString(),
        'isActive': true,
      });

      emitSuccess(successResponse: 'Group created successfully');
    } catch (error) {
      emitFailure(failureResponse: 'Failed to create group');
    }
  }
}
