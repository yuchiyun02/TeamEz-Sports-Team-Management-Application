import 'package:flutter/material.dart';
import 'package:teamez/constant/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      obscuringCharacter: '*',
      validator: validator,
      decoration: InputDecoration(
        fillColor: CustomCol.silver,
        filled: true,
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(color: CustomCol.darkGrey),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: CustomCol.black),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CustomCol.black),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}