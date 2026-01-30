import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/screens/clients/family_addition_form/widgets/crn_search_tile.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class AddFamilyCrnSearchScreen extends StatelessWidget {
  AddFamilyCrnSearchScreen() {
    Get.find<ClientFamilyController>().clearSearchBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: GetBuilder<ClientFamilyController>(
          builder: (controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(controller, context),
                Expanded(
                  child: _buildSearchResultSection(controller, context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    ClientFamilyController controller,
    BuildContext context,
  ) {
    return BorderedTextFormField(
      autoFocus: true,
      hintStyle: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
            color: ColorConstants.textFieldHintColor,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
      inputFormatters: [
        NoLeadingSpaceFormatter(),
      ],
      enabled: !controller.isCRNClientSelected,
      keyboardType: TextInputType.text,
      prefixIcon: controller.isCRNClientSelected
          ? Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${controller.CRNSelectedClient!.name!.toTitleCase()} | ${controller.CRNSelectedClient!.crn!.toUpperCase()} ',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                      ),
                ),
              ),
            )
          : Icon(
              Icons.search,
              color: ColorConstants.primaryAppColor,
            ),
      hintText: controller.isCRNClientSelected
          ? ''
          : 'Search Family Member for CRN Number',
      label: 'Family Member',
      labelStyle: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
            color: ColorConstants.tertiaryBlack,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
      suffixIcon: controller.crnController!.text.isNotNullOrEmpty &&
              !controller.isCRNClientSelected
          ? IconButton(
              onPressed: () {
                controller.clearSearchBar();
              },
              icon: Icon(
                Icons.clear,
                color: ColorConstants.primaryAppColor,
              ),
            )
          : controller.isCRNClientSelected
              ? IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.edit,
                    color: ColorConstants.primaryAppColor,
                  ),
                )
              : SizedBox(),
      onChanged: (val) {
        if (val.isNotNullOrEmpty && controller.searchQuery != val) {
          controller.searchClientForCRN(val);
        }
      },
      controller: controller.crnController,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value.isNullOrEmpty && controller.CRNSelectedClient == null) {
          return 'CRN Number is required.';
        }
        return null;
      },
    );
  }

  Widget _buildSearchResultSection(
    ClientFamilyController controller,
    BuildContext context,
  ) {
    if (controller.searchState == NetworkState.loading)
      return SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    if (controller.searchState == NetworkState.loaded) {
      if (controller.clientsResult.clients.isNotNullOrEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Search Results',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryGrey,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: controller.clientsResult.clients!.length,
                  itemBuilder: (context, index) {
                    return CRNSearchTile(
                      effectiveIndex: index % 7,
                      client: controller.clientsResult.clients![index],
                      onTap: () {
                        controller.updateCRNSelectedClient(
                            controller.clientsResult.clients![index]);
                        AutoRouter.of(context).popForced();
                      },
                    );
                  },
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(
                      thickness: 0.3,
                      color: ColorConstants.darkGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Center(
          child: EmptyScreen(
            imagePath: AllImages().clientSearchEmptyIcon,
            imageSize: 92,
            message:
                "Client not found! Please make sure client is assigned to your account",
          ),
        );
      }
    }

    if (controller.searchState == NetworkState.error) {
      return SizedBox(
        height: 100,
        child: Center(
          child: RetryWidget(
            controller.clientsErrorMessage,
            onPressed: () => controller.searchClientForCRN(
              controller.crnController!.text,
            ),
          ),
        ),
      );
    }

    return SizedBox();
  }
}
