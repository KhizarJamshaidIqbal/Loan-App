import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String text;
  final String url;
  const Avatar({super.key, required this.text, required this.url});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: NetworkImage(
            url,
          ),
        ),
        Text(text)
      ],
    );
  }
}
