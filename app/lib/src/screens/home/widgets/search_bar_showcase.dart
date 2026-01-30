// import 'package:app/src/controllers/showcase/showcase_controller.dart';
// import 'package:app/src/controllers/store/store_search_controller.dart';
// import 'package:app/src/screens/home/widgets/search_section.dart';
// import 'package:app/src/widgets/misc/show_case_wrapper.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:showcaseview/showcaseview.dart';

// class SearchBarShowCase extends StatelessWidget {
//   const SearchBarShowCase({
//     Key? key,
//     required this.showCaseWrapperKey,
//     required this.focusNode,
//     this.onClickFinished,
//     this.storeSearchController,
//     this.showCaseController,
//   }) : super(key: key);

//   final Key showCaseWrapperKey;
//   final FocusNode? focusNode;
//   final Function? onClickFinished;
//   final StoreSearchController? storeSearchController;
//   final ShowCaseController? showCaseController;

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ShowCaseController>(
//         id: 'update-showcase-index',
//         builder: (controller) {
//           // This controller will also trigger when user use deeplink or push notification to navigate to another screen
//           // Then we call onClickFinished, otherwise the showcase would still be visible on top of the new screen
//           if (controller.activeShowCaseId != showCaseIds.HomeSearchBar.id) {
//             WidgetsBinding.instance.addPostFrameCallback((t) {
//               onClickFinished!();
//             });
//             return SizedBox();
//           }

//           return ShowCaseWidget(
//             disableScaleAnimation: true,
//             disableBarrierInteraction: false,
//             onStart: (index, key) {
//               LogUtil.printLog("here");
//             },
//             onFinish: () async {
//               if (showCaseController!.activeShowCaseId ==
//                   showCaseIds.HomeSearchBar.id) {
//                 await showCaseController!.setActiveShowCase();
//                 onClickFinished!();
//               }
//             },
//             builder: Builder(
//               builder: (context) {
//                 return ShowCaseWrapper(
//                   key: showCaseWrapperKey,
//                   focusNode: focusNode,
//                   currentShowCaseId: showCaseIds.HomeSearchBar.id,
//                   minRadius: 12,
//                   maxRadius: 24,
//                   constraints: BoxConstraints(
//                     maxHeight: 86,
//                     minHeight: 50,
//                     maxWidth: MediaQuery.of(context).size.width,
//                     minWidth: MediaQuery.of(context).size.width - 50,
//                   ),
//                   onTargetClick: () async {
//                     await showCaseController!.setActiveShowCase();
//                     ShowCaseWidget.of(context).next();
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       focusNode!.requestFocus();
//                     });
//                     onClickFinished!();
//                   },
//                   rippleExpandingHeight: 86,
//                   rippleExpandingWidth: double.maxFinite,
//                   child: Align(
//                     alignment: Alignment.center,
//                     child: InkWell(
//                       onTap: () async {
//                         String activeShowCaseId =
//                             showCaseController!.activeShowCaseId;

//                         if (activeShowCaseId == showCaseIds.HomeSearchBar.id) {
//                           await showCaseController!
//                               .setActiveShowCase(); // await Future.delayed(Duration(seconds: 2), () {
//                           ShowCaseWidget.of(context).next();
//                           onClickFinished!();
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             focusNode!.requestFocus();
//                           });
//                         }
//                       },
//                       child: IgnorePointer(
//                         ignoring: true,
//                         child: SearchBarContainer(
//                           focusNode: focusNode,
//                           universalSearchController: universalSearchController,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         });
//   }
// }
