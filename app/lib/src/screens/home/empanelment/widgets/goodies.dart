import 'package:app/src/config/constants/image_constants.dart';
import 'package:flutter/material.dart';

class Goodies extends StatelessWidget {
  const Goodies({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goodies',
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset(
                    AllImages().laptopBag,
                    width: 34,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Laptop\nBag',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  )
                ],
              ),
              Column(
                children: [
                  Image.asset(
                    AllImages().wealthyPartnerCertificate,
                    width: 34,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Wealthy Partner\nCertificate',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
