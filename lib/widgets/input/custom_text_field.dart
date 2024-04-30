import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {super.key,
      required this.nameController,
      required this.hintText,
      required this.lable,
      required this.keyboardType,
      required this.validator});
  String lable;
  String hintText;
  final TextEditingController nameController;
  TextInputType keyboardType;
  String? Function(String?) validator;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        keyboardType: keyboardType,
        validator: validator,
        controller: nameController,
        decoration: InputDecoration(
            label: Text(lable),
            hintText: hintText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            )),
      ),
    );
  }
}
