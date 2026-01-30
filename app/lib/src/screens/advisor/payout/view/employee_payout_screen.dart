import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/screens/advisor/payout/widgets/employee_payout_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/payout_model.dart';
import 'package:flutter/material.dart';

@RoutePage()
class EmployeePayoutScreen extends StatelessWidget {
  final List<PayoutModel> employeesPayouts;

  const EmployeePayoutScreen({Key? key, required this.employeesPayouts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Employee Wise Segregation',
      ),
      body: ListView.separated(
        itemCount: employeesPayouts.length,
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          return EmployeePayoutCard(
            employeePayout: employeesPayouts[index],
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 10);
        },
      ),
    );
  }
}
