import 'package:app/src/config/routes/route_name.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SupportScreen extends StatefulWidget {
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  void initState() {
    super.initState();
    handleFreshchatDeeplink(AppRouteName.supportScreen, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
