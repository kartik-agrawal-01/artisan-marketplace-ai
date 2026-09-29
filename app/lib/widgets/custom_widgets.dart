import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;


  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.obscureText = false,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],

        ),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[600]!,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.indigo,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.indigo,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 20.0,
        ),
        focusColor: Colors.blue,
      ),
      style: GoogleFonts.roboto(
        color: Colors.grey[900],
      ),
    );
  }
}
