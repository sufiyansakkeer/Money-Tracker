import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'dart:math' as math;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 280,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConstants.themeColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    width: double.infinity,
                    height: 140,
                  ),

                  Positioned(
                    top: 20,
                    left: 30,
                    right: 30,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return SweepGradient(
                          center: Alignment.topCenter,
                          startAngle: 0.1,
                          endAngle: math.pi * 0.9,
                          colors: [
                            ColorConstants.expenseColor,
                            ColorConstants.themeColor,
                            ColorConstants.incomeColor,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      child: Container(
                        height: 250,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                          border: Border.all(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 20,
                    left: 30,
                    right: 30,
                    child: Padding(
                      padding: EdgeInsets.only(top: 30, bottom: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                70 < 0 ? 'Lose' : 'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                //here i used abs to avoid the negative values
                                '₹77777777',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward_outlined,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Income',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '₹8888',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward_outlined,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Expense',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '₹ 99999',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // softWrap: false,
                                    // maxLines: 1,
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )

                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
