import 'package:flutter/material.dart';

class ExpenseTransaction extends StatelessWidget {
  const ExpenseTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        itemCount: 10,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10.0,
          childAspectRatio: (2 / 1.2),
        ),
        itemBuilder: ((
          context,
          index,
        ) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 5,
              top: 10,
              right: 5,
            ),
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                  color: Colors.amber,
                ),
                height: 20,
                width: 20,
              ),
            ),
          );
        }),
      ),
    );
  }
}
