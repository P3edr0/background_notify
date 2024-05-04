import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormWidget extends StatelessWidget {
  const TextFormWidget(
      {super.key,
      required this.title,
      required this.controller,
      this.isPassword = false,
      this.action = TextInputAction.next,
      this.keyboardType = TextInputType.text,
      this.mask});

  final String title;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputAction action;
  final TextInputType keyboardType;
  final TextInputFormatter? mask;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        title,
        style: TextStyle(
            color: Colors.blue[700]!,
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
      Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.blue[700]!.withOpacity(0.8),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Form(
            child: TextField(
          obscureText: isPassword,
          controller: controller,
          textInputAction: action,
          keyboardType: keyboardType,
          inputFormatters: mask != null ? [mask!] : [],
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
        )),
      )
    ]);
  }
}
