import 'package:app/src/config/routes/route_name.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FaqScreen extends StatefulWidget {
  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  @override
  void initState() {
    super.initState();
    handleFreshchatDeeplink(AppRouteName.faqScreen, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
