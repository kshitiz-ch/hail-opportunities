import 'dart:io';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ChooseProfilePictureBottomSheet extends StatelessWidget {
  ProfileController profileController = Get.find<ProfileController>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      id: 'profile-picture',
      builder: (controller) {
        profileController = controller;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18, right: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: CommonUI.bottomsheetCloseIcon(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Choose Profile Picture',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.black,
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              child: SizedBox(
                height: 90,
                child: _buildProfileAvatarList(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: CommonUI.buildProfileDataSeperator(
                      color: ColorConstants.secondarySeparatorColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Or',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ),
                  Expanded(
                    child: CommonUI.buildProfileDataSeperator(
                      color: ColorConstants.secondarySeparatorColor,
                    ),
                  ),
                ],
              ),
            ),
            if (controller.pickedImage == null)
              _buildUploadButton(context)
            else
              _buildImagePreview(context),
            _buildUpdateButton(context),
          ],
        );
      },
    );
  }

  Widget _buildProfileAvatarList(BuildContext context) {
    final profileAvatarList = <String>[
      AllImages().profileIcon,
      AllImages().profileAvatar1,
      AllImages().profileAvatar2,
      AllImages().profileAvatar3,
      AllImages().profileAvatar4,
      AllImages().profileAvatar5,
      AllImages().profileAvatar6,
      AllImages().profileAvatar7,
      AllImages().profileAvatar8,
    ];

    return ListView.builder(
      itemCount: profileAvatarList.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final isSelected =
            profileController.selectedAvatar == profileAvatarList[index];
        return Padding(
          padding: const EdgeInsets.only(left: 20),
          child: InkWell(
            onTap: () {
              profileController.pickedImage = null;
              profileController.selectedAvatar = profileAvatarList[index];
              profileController.update(['profile-picture']);
            },
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: ColorConstants.white,
                      radius: 32,
                      backgroundImage: AssetImage(profileAvatarList[index]),
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 6, top: 6),
                        child: Text(
                          'Selected',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge
                              ?.copyWith(
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      )
                  ],
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 25,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.primaryAppColor,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.done,
                        color: ColorConstants.white,
                        size: 15,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return ActionButton(
      onPressed: () {
        CommonUI.showBottomSheet(
          context,
          child: UploadOptionsBottomSheet(
            onTap: (imageSource) {
              getImage(imageSource);
            },
          ),
          isScrollControlled: false,
        );
      },
      text: 'Upload Profile Picture',
      textStyle: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: ColorConstants.primaryAppColor,
          ),
      showBorder: true,
      bgColor: ColorConstants.white,
      borderRadius: 16,
      borderColor: ColorConstants.primaryAppColor,
      height: 54,
      margin: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      prefixWidget: Icon(
        Icons.file_upload_outlined,
        size: 24,
        color: ColorConstants.primaryAppColor,
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return ActionButton(
      isDisabled: profileController.selectedAvatar.isNullOrEmpty &&
          profileController.pickedImage == null,
      showProgressIndicator:
          profileController.uploadImageResponse.state == NetworkState.loading,
      onPressed: () async {
        await profileController.uploadProfilePhoto();
        if (profileController.uploadImageResponse.state ==
            NetworkState.loaded) {
          profileController.selectedAvatar = null;
          profileController.pickedImage = null;
          profileController.getProfilePhoto();
          AutoRouter.of(context).popForced();
        }
      },
      text: 'Update',
      margin: EdgeInsets.symmetric(vertical: 30, horizontal: 24),
    );
  }

  Future<void> getImage(ImageSource imageSource) async {
    final ImagePicker _picker = ImagePicker();
    final pickedImage =
        await _picker.pickImage(source: imageSource, maxWidth: 1000);
    if (pickedImage != null) {
      final croppedImage = await _cropImage(File(pickedImage.path));
      profileController.pickedImage =
          File(croppedImage?.path ?? pickedImage.path);
      profileController.selectedAvatar = null;
      profileController.update(['profile-picture']);
    }
  }

  Future<CroppedFile?> _cropImage(File? pickedImage) async {
    CroppedFile? croppedFile;
    if (pickedImage != null) {
      final sourceImageSize = await pickedImage.length();
      croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        compressFormat: ImageCompressFormat.png,
        compressQuality: getCompressionPercent(sourceImageSize),
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            initAspectRatio: CropAspectRatioPreset.square,
            statusBarColor: ColorConstants.primaryAppColor,
            toolbarWidgetColor: ColorConstants.primaryAppColor,
            activeControlsWidgetColor: ColorConstants.primaryAppColor,
            showCropGrid: false,
            hideBottomControls: true,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            minimumAspectRatio: 1,
            rotateButtonsHidden: true,
            rotateClockwiseButtonHidden: true,
            aspectRatioPickerButtonHidden: true,
            resetButtonHidden: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );
    }
    return croppedFile;
  }

  int getCompressionPercent(int sourceImageSize) {
    double requiredImageSize = 500 * 1024; // 500KB
    if (sourceImageSize <= requiredImageSize) {
      return 100; // no compression
    }
    final compressPercent = (requiredImageSize * 100) / sourceImageSize;
    return compressPercent.isNullOrZero || compressPercent.isNegative
        ? 100
        : compressPercent.ceil();
  }

  Widget _buildImagePreview(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              decoration: BoxDecoration(
                color: ColorConstants.darkGrey,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(1),
              child: CircleAvatar(
                backgroundColor: ColorConstants.white,
                radius: 50,
                backgroundImage: FileImage(profileController.pickedImage!),
              ),
            ),
          ),
          ClickableText(
            text: 'Change',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            onClick: () {
              CommonUI.showBottomSheet(
                context,
                child: UploadOptionsBottomSheet(
                  onTap: (imageSource) {
                    getImage(imageSource);
                  },
                ),
                isScrollControlled: false,
              );
            },
            padding: EdgeInsets.symmetric(vertical: 24),
          )
        ],
      ),
    );
  }
}

class UploadOptionsBottomSheet extends StatelessWidget {
  final Function(ImageSource) onTap;

  const UploadOptionsBottomSheet({Key? key, required this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ImageSource.values
            .map(
              (uploadInfo) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: InkWell(
                  onTap: () {
                    AutoRouter.of(context).popForced();
                    onTap(uploadInfo);
                  },
                  child: Row(
                    children: [
                      Icon(
                        uploadInfo == ImageSource.camera
                            ? Icons.camera
                            : Icons.photo_library,
                        color: ColorConstants.primaryAppColor,
                        size: 24,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Upload via ${uploadInfo.name.toCapitalized()}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium
                              ?.copyWith(
                                color: ColorConstants.black,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
