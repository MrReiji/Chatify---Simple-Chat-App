import 'package:chatify/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:chatify/constants/constants.dart';
import 'package:chatify/design_widgets/buttons/primary_button.dart';
import 'package:chatify/design_widgets/fields/input_widget.dart';
import 'package:chatify/design_widgets/fields/user_image_picker.dart';
import 'package:chatify/blocs/chat/group_creation_form_bloc.dart';
import 'package:chatify/design_widgets/dialogs/loading_dialog.dart';

class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  _GroupCreationScreenState createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupCreationFormBloc(),
      child: Builder(
        builder: (context) {
          final groupCreationFormBloc = context.read<GroupCreationFormBloc>();

          return Scaffold(
            appBar: AppBar(
              title: const Text("Create Group Chat"),
              backgroundColor: kPrimaryColor,
            ),
            body: FormBlocListener<GroupCreationFormBloc, String, String>(
              onSubmitting: (context, state) => LoadingDialog.show(context),
              onSubmissionFailed: (context, state) => LoadingDialog.hide(context),
              onSuccess: (context, state) async {
                LoadingDialog.hide(context);
                final groupId = state.successResponse; // Zakładam, że zwraca ID grupy
                await subscribeToChatTopic(groupId!); // Subskrypcja na temat po utworzeniu grupy
                Navigator.pop(context, true); // Powrót na ekran poprzedni po utworzeniu
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse!)),
                  );
                }
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
                          "Create a New Group",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                        const SizedBox(height: kDefaultPadding),

                        // Group image selection
                        UserImagePicker(
                          onPickImage: (pickedImage) {
                            groupCreationFormBloc.selectedImage = pickedImage;
                          },
                        ),
                        const SizedBox(height: kDefaultPadding / 2),

                        // Group name input field
                        InputWidget(
                          hintText: "Group Name",
                          prefixIcon: Icons.group,
                          fieldBloc: groupCreationFormBloc.groupName,
                        ),

                        // Dynamic participants fields
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

                        // Create Group button
                        PrimaryButton(
                          text: "Create Group",
                          press: () => groupCreationFormBloc.submit(),
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

  Future<void> subscribeToChatTopic(String groupId) async {
    NotificationService().subscribeToTopic('group_$groupId');
    debugPrint('Subscribed to topic: group_$groupId');
  }
}
