import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    super.key,
    required this.onPickImage,
    this.initialImageUrl,
  });

  final void Function(File pickedImage) onPickImage;
  final String? initialImageUrl;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  late String? _imageToShow;

  @override
  void initState() {
    super.initState();
    // Ustaw początkowy obraz, jeśli jest dostępny
    _imageToShow = widget.initialImageUrl;
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
      _imageToShow = null; // Jeśli wybierze nowe zdjęcie, przestajemy wyświetlać początkowy URL
    });

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.grey.withOpacity(0.2),
          foregroundImage: _pickedImageFile != null
              ? FileImage(_pickedImageFile!)
              : (_imageToShow != null
                  ? NetworkImage(_imageToShow!)
                  : null),
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        )
      ],
    );
  }
}
