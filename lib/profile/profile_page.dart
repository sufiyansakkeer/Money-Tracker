import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/iPhone 8 - 2.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0x00000000),
          leading: IconButton(
            onPressed: (() {}),
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(),
        ),
      ),
    );
  }
}
