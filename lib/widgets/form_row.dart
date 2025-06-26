import 'package:flutter/material.dart';

class FormRow extends StatelessWidget {
  final List<Widget> children;
  const FormRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: children[0]),
          const SizedBox(width: 20),
          if (children.length > 1) Expanded(child: children[1]),
        ],
      ),
    );
  }
}
