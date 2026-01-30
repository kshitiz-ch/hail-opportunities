import 'dart:io';
import 'dart:typed_data';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/client_birthdays_controller.dart';
import 'package:app/src/utils/birthday_card_service.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

@RoutePage()
class BirthdayWishScreen extends StatelessWidget {
  final Client client;

  BirthdayWishScreen({Key? key, required this.client}) : super(key: key) {
    if (!Get.isRegistered<ClientBirthdaysController>()) {
      Get.put(ClientBirthdaysController());
    }

    MixPanelAnalytics.trackWithAgentId(
      "birthday_wish",
      screen: 'birthday_wish_screen',
      screenLocation: 'birthday_wish_screen',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(titleText: 'Add your Birthday Wish'),
      body: GetBuilder<ClientBirthdaysController>(
        initState: (_) {
          Get.find<ClientBirthdaysController>().onInitWishScreen(client);
        },
        builder: (controller) {
          if (controller.brandingUrlResponse.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Don't show error state for branding URL response
          // show default posters
          // if (controller.brandingUrlResponse.isError) {
          //   return Center(
          //     child: RetryWidget(
          //       controller.brandingUrlResponse.message,
          //       onPressed: () {
          //         controller.getBrandingUrl();
          //       },
          //     ),
          //   );
          // }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24)
                .copyWith(bottom: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client Name Section
                Center(
                  child: Text(
                    client.name ?? '',
                    textAlign: TextAlign.center,
                    style: context.headlineLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.black,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                _buildPostersList(controller, context),
                SizedBox(height: 44),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Your Message Section
                    _buildHeader('Your Message', context),
                    _buildRegenerateButton(controller),
                  ],
                ),

                SizedBox(height: 4),

                _buildTextField(
                  textController: controller.messageController,
                  context: context,
                  isMessageBox: true,
                ),

                SizedBox(height: 32),

                // Your Name Section
                _buildHeader('Your Name', context),
                SizedBox(height: 4),

                // Name Input
                _buildTextField(
                  textController: controller.nameController,
                  context: context,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildCTA(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTextField({
    required TextEditingController textController,
    required BuildContext context,
    bool isMessageBox = false,
  }) {
    String hintText = isMessageBox ? 'Write your message' : 'Write your name';
    final style = context.headlineSmall
        ?.copyWith(fontWeight: FontWeight.w500, color: Colors.black);

    final height = isMessageBox ? 150.0 : 50.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: style,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          hintText: hintText,
          hintStyle: style?.copyWith(color: ColorConstants.tertiaryBlack),
          border: InputBorder.none,
          // contentPadding: EdgeInsets.all(16),
        ),
        onChanged: (value) {
          // Update the controller's wish when user types
          // controller.updateMessage(value);
        },
      ),
    );
  }

  Widget _buildHeader(String title, BuildContext context) {
    return Text(
      title,
      style: context.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildRegenerateButton(ClientBirthdaysController controller) {
    return ClickableText(
      onClick: () {
        controller.generateBirthdayWish(client);
      },
      text: 'Regenerate',
      fontSize: 14,
      textColor: ColorConstants.primaryAppColor,
      prefixIcon: controller.birthdayWishResponse.isLoading
          ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      ColorConstants.primaryAppColor),
                ),
              ),
            )
          : Icon(
              Icons.refresh,
              color: ColorConstants.primaryAppColor,
              size: 20,
            ),
    );
  }

  Widget _buildPostersList(
    ClientBirthdaysController controller,
    BuildContext context,
  ) {
    final posterCards = List.generate(
      controller.birthdayPosterImages.length,
      (index) {
        final posterBranding = controller.createdPosters.length > index
            ? controller.createdPosters[index]
            : null;
        final posterOriginal = controller.birthdayPosterImages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: posterBranding == null
              ? Image.asset(
                  posterOriginal,
                  fit: BoxFit.fill,
                )
              : Image.memory(
                  posterBranding,
                  fit: BoxFit.fill,
                ),
        );
      },
      growable: false,
    ).toList();

    return Container(
      height: 400,
      child: Swiper(
        itemCount: posterCards.length,
        itemBuilder: (context, index) {
          return posterCards[index];
        },
        // Fix: Explicitly set the index to maintain poster selection during rebuilds
        // This ensures that when the "Regenerate" button is clicked and the UI rebuilds,
        // the swiper stays on the current poster instead of jumping back to index 0
        index: controller.currentPosterIndex,
        outer: false,
        loop: false,
        // Update the controller's currentPosterIndex when user swipes to a different poster
        onIndexChanged: (index) {
          controller.currentPosterIndex = index;
        },
        // Dot pagination indicator at the bottom of the swiper
        pagination: SwiperPagination(
          // margin: EdgeInsets.symmetric(),
          builder: DotSwiperPaginationBuilder(
            size: 8,
            activeSize: 8,
            activeColor: posterCards.length <= 1
                ? Colors.transparent
                : ColorConstants.primaryAppColor,
            color: posterCards.length <= 1
                ? Colors.transparent
                : ColorConstants.primaryAppColor.withOpacity(0.16),
          ),
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
      child: GetBuilder<ClientBirthdaysController>(
        builder: (controller) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ActionButton(
                  text: 'Download Card',
                  showProgressIndicator:
                      controller.birthdayCardDownloadResponse.isLoading,
                  onPressed: () async {
                    // Handle download card button press
                    await controller
                        .downloadBirthdayCard(client.name ?? 'Client');
                    showToast(
                        text: controller.birthdayCardDownloadResponse.message);
                  },
                  progressIndicatorColor: ColorConstants.primaryAppColor,
                  showBorder: true,
                  borderColor: ColorConstants.primaryAppColor,
                  bgColor: ColorConstants.secondaryAppColor,
                  borderRadius: 51,
                  margin: EdgeInsets.zero,
                  textStyle: context.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.primaryAppColor,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  text: 'Wish Client ',
                  onPressed: () {
                    // Handle wish client button press
                    wishClient(controller);
                  },
                  borderRadius: 51,
                  margin: EdgeInsets.zero,
                  textStyle: context.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String getBirthdayMessage(ClientBirthdaysController controller) {
    if (controller.nameController.text.isEmpty) {
      showToast(text: 'Please enter your name');
      return '';
    }
    if (controller.messageController.text.isEmpty) {
      showToast(text: 'Please enter your message');
      return '';
    }

    String message = controller.messageController.text;
    message += '\n\nBest wishes,\n${controller.nameController.text}';

    return message;
  }

  Future<void> wishClient(ClientBirthdaysController controller) async {
    final message = getBirthdayMessage(controller);

    if (message.isEmpty) {
      return;
    }

    try {
      // Get the current poster image
      final currentIndex = controller.currentPosterIndex;
      Uint8List? imageBytes;

      if (currentIndex < controller.createdPosters.length &&
          controller.createdPosters[currentIndex] != null) {
        // Use the branded poster if available
        imageBytes = controller.createdPosters[currentIndex];
      } else {
        // Fallback to original poster (need to load as bytes)
        final posterPath = controller.birthdayPosterImages[currentIndex];

        imageBytes = await BirthdayCardService.loadImageBytes(posterPath);
      }

      if (imageBytes != null) {
        // Save image to temporary file
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'birthday_card_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(imageBytes);

        // Share image with message via WhatsApp
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'image/png')],
            text: message,
            sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
          ),
        );
      }
    } catch (e) {
      showToast(text: 'Error sharing to WhatsApp: $e');
    }
  }
}
