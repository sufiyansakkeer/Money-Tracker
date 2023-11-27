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
      body: const Padding(
        padding: EdgeInsets.all(80.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Money Track',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Developed by Sufiyan Sakkeer ",
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Version 1.0.2',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
