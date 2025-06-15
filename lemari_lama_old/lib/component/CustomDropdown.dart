// custom_dropdown.dart
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool isUpdate;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.isUpdate,
    this.value,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            "$label :",
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF544C2A),
            ),
          ),
        ),
        DropdownButtonFormField<T>(
          hint: Text("Pilih ${label}"),
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color.fromARGB(255, 255, 255, 255),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFBDBDBD)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF544C2A), width: 2),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          value: isUpdate ? value : null,
          items: items,
          onChanged: onChanged,
          validator: validator,
        )
      ]
    );
  }
}
