import 'dart:io';
import 'package:flutter/material.dart';

class EditableTextField extends StatefulWidget {
  final String title;
  final Function(String) onSubmit;

  const EditableTextField({
    required this.title,
    required this.onSubmit,
    super.key,
  });

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isEditing
        ? TextField(
            controller: _controller,
            autofocus: true,
            onSubmitted: (value) {
              setState(() {
                _isEditing = false;
              });
              widget.onSubmit(value);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          )
        : GestureDetector(
            onDoubleTap: () {
              setState(() {
                _isEditing = true;
              });
            },
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 16),
            ),
          );
  }
}


