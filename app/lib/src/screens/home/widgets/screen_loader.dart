import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:flutter/material.dart';

class HomeScreenLoader extends StatelessWidget {
  const HomeScreenLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Header
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 48, bottom: 32),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ).toShimmer(),
                    SizedBox(width: 14),
                    Container(
                      height: 22,
                      width: 120,
                      color: Colors.grey,
                    ).toShimmer()
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  ).toShimmer(),
                  SizedBox(width: 14),
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  ).toShimmer(),
                ],
              )
            ],
          ),
        ),

        // Search Section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          width: double.infinity,
          height: 56,
          color: Colors.grey,
        ).toShimmer(),
        SizedBox(
          height: 50,
        ),

        // Earning Text
        Center(
          child: Container(
            width: 120,
            height: 20,
            color: Colors.grey,
          ),
        ).toShimmer(),

        SizedBox(
          height: 14,
        ),

        // Earning Value
        Center(
          child: Container(
            width: 80,
            height: 30,
            color: Colors.grey,
          ),
        ).toShimmer(),

        Container(
          margin: const EdgeInsets.all(20.0),
          height: 56,
          child: Row(
            children: [
              // Monthly Planner Button
              Expanded(
                child: Container(
                  color: Colors.grey,
                ).toShimmer(),
              ),
              SizedBox(
                width: 20,
              ),
              // Revenue Sheet  Button
              Expanded(
                child: Container(
                  color: Colors.grey,
                ).toShimmer(),
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 170,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Pending Proposal Count
                    Expanded(
                      child: Center(
                        child: Container(
                          height: 60,
                          width: 130,
                          color: Colors.grey,
                        ).toShimmer(),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    // Completed Proposal Count
                    Expanded(
                      child: Center(
                        child: Container(
                          height: 60,
                          width: 130,
                          color: Colors.grey,
                        ).toShimmer(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Active SIP Count
                    Expanded(
                      child: Center(
                        child: Container(
                          height: 25,
                          width: 100,
                          color: Colors.grey,
                        ).toShimmer(),
                      ),
                    ),
                    // SIP Book Button
                    Expanded(
                      child: Center(
                        child: Container(
                          height: 25,
                          width: 100,
                          color: Colors.grey,
                        ).toShimmer(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 50),
        // Manager Card text
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20).copyWith(right: 200),
          height: 20,
          width: 130,
          color: Colors.grey,
        ).toShimmer(),
        SizedBox(height: 20),
        // Manager Card
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: 150,
          color: Colors.grey,
        ).toShimmer(),
      ],
    );
  }
}
