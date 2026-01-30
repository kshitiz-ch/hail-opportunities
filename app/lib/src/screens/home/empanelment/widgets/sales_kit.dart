import 'package:app/src/config/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SalesKit extends StatelessWidget {
  const SalesKit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Kit',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineMedium!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 18),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    AllImages().wealthyGuidebook,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Illustrative Equity Guidebook for Client Acquisition',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Image.asset(
                    AllImages().clientPlanner,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Hardcover Client Planner',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Image.asset(
                    AllImages().visitingCard,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Business cards',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
