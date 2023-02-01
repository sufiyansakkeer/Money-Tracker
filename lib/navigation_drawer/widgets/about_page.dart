import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: const Color(0x00000000),
        leading: IconButton(
          onPressed: (() {
            Navigator.of(context).pop();
          }),
          icon: Icon(
            Icons.adaptive.arrow_back,
            // color: themeDarkBlue,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'About',
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Money Track',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
            Text("Developed by Sufiyan Sakkeer ")
          ],
        ),
      ),
    );
  }
}
