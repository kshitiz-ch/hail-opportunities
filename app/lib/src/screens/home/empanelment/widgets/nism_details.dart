import 'package:app/src/config/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class NismDetails extends StatelessWidget {
  const NismDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NISM VA Exam',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineMedium!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 18),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 34, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    AllImages().nismTraining,
                    width: 44,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Exam fees and\nregistration',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    AllImages().nismStudyMaterial,
                    width: 46,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Training, study materials\nand mock tests',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
