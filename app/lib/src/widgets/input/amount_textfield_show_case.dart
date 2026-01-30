// import 'package:app/src/config/constants/color_constants.dart';
// import 'package:app/src/config/extension_utils.dart';
// import 'package:app/src/controllers/showcase/showcase_controller.dart';
// import 'package:app/src/utils/wealthy_amount.dart';
// import 'package:app/src/widgets/input/amount_textfield.dart';
// import 'package:app/src/widgets/misc/common_ui.dart';
// import 'package:app/src/widgets/misc/show_case_wrapper.dart';
// import 'package:core/modules/common/resources/wealthy_cast.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:showcaseview/showcaseview.dart';

// class AmountTextFieldShowCaseWidget extends StatelessWidget {
//   const AmountTextFieldShowCaseWidget({
//     Key key,
//     @required this.showCaseWrapperKey,
//     @required this.focusNode,
//     this.showCaseController,
//     this.amountTextFieldWidget,
//     this.onClickFinished,
//   }) : super(key: key);

//   final Key showCaseWrapperKey;
//   final FocusNode focusNode;
//   final ShowCaseController showCaseController;
//   final AmountTextField amountTextFieldWidget;
//   final Function onClickFinished;

//   @override
//   Widget build(BuildContext context) {
//     return ShowCaseWidget(
//       disableBarrierInteraction: false,
//       onStart: (index, key) {},
//       onFinish: () async {
//         if (showCaseController.activeShowCaseId ==
//             showCaseIds.AmountTextField.id) {
//           await showCaseController.setActiveShowCase();
//           onClickFinished(); // await Future.delayed(Duration(seconds: 2), () {
//         }
//       },
//       builder: Builder(
//         builder: (context) {
//           return ShowCaseWrapper(
//             key: showCaseWrapperKey,
//             focusNode: focusNode,
//             onTargetClick: () async {
//               if (showCaseController.activeShowCaseId ==
//                   showCaseIds.AmountTextField.id) {
//                 await showCaseController.setActiveShowCase();
//               }
//               ShowCaseWidget.of(context).next();
//               onClickFinished();
//               FocusScope.of(context).requestFocus(focusNode);
//             },
//             extraSpacing: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//             rippleExpandingHeight: 56,
//             rippleExpandingWidth: MediaQuery.of(context).size.width,
//             currentShowCaseId: showCaseIds.AmountTextField.id,
//             minRadius: 5,
//             maxRadius: 10,
//             constraints: BoxConstraints(
//               maxHeight: 66,
//               minHeight: 46,
//               maxWidth: MediaQuery.of(context).size.width + 10,
//               minWidth: MediaQuery.of(context).size.width - 60,
//             ),
//             child: Container(
//                 color: Colors.white,
//                 key: showCaseWrapperKey,
//                 child: AmountTextFieldContainer(
//                     focusNode: focusNode,
//                     widget: amountTextFieldWidget,
//                     showCaseController: showCaseController,
//                     onClickFinished: onClickFinished)),
//           );
//         },
//       ),
//     );
//   }
// }
