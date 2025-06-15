import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String label;
  final Icon? icon;
  final bool hash;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final int maxLines;
  final bool enabled;

  const CustomFormField({
    Key? key,
    required this.label,
    this.icon,
    this.hash = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.controller,
    this.onChanged,
    this.onSaved,
    this.maxLines = 1,
    this.enabled = true,
  }) : super(key: key);

  @override
  _CustomFormFieldState createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.hash;
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Color(0xFF544C2A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            "${widget.label} :",
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        TextFormField(
          obscureText: _obscure,
          cursorColor: primaryColor,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: widget.icon,
            suffixIcon: widget.hash
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
            labelStyle: TextStyle(color: primaryColor),
            filled: true,
            fillColor: Color.fromARGB(255, 255, 255, 255),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFBDBDBD)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          controller: widget.controller,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
        ),
      ],
    );
  }
}
