import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/quick_action_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/advisor/models/quick_action_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class QuickActionEditScreen extends StatelessWidget {
  QuickActionController _controller = Get.find<QuickActionController>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuickActionController>(
      builder: (controller) {
        _controller = controller;
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Edit Quick Actions',
            onBackPress: () {
              controller.onClose();
              AutoRouter.of(context).popForced();
            },
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25)
                      .copyWith(bottom: 30),
                  child: Text(
                    '*Please add at least ${controller.minAllowedActions} actions & at most ${controller.maxAllowedActions} actions in quick action section',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.tertiaryBlack,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: _buildActionList(context: context, isSelected: true),
                ),
                _buildActionList(context: context, isSelected: false),
                SizedBox(height: 100),
              ],
            ),
          ),
          floatingActionButton: _buildCTA(context, controller),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Widget _buildActionList(
      {required BuildContext context, required bool isSelected}) {
    late String title;
    late String subtitle;
    late List<QuickActionModel> actionData;
    late String emptyText;
    if (isSelected) {
      title = 'Remove actions';
      subtitle =
          'Tap on icon to remove action\nDrag and drop to reorder or move actions';
      actionData = _controller.selectedActions;
      emptyText = 'No action available in quick action section';
    } else {
      title = 'Add actions';
      subtitle =
          'Tap on icon to remove action\nDrag and drop to reorder or move actions';
      actionData = _controller.unselectedActions;
      emptyText = 'No action available in add section';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 30),
            child: Text(
              subtitle,
              style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
          if (actionData.isNotNullOrEmpty)
            _buildGridView(actionData, context, isSelected)
          else
            _buildEmptyActionView(emptyText)
        ],
      ),
    );
  }

  Widget _buildGridView(
    List<QuickActionModel> actionData,
    BuildContext context,
    bool isSelected,
  ) {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 4,
      childAspectRatio: 0.7,
      children: List<Widget>.generate(
        // get nearest multiple of crossAxisCount ie 4
        // to fill empty spaces for drag & drop on empty sizedbox
        ((actionData.length + 3) ~/ 4) * 4,
        (index) {
          if (index >= actionData.length) {
            return DragTarget<QuickActionModel>(
              onAcceptWithDetails: (details) {},
              onAccept: (dragAction) {
                _controller.onDropAction(dragAction, null);
              },
              builder: (context, a, b) {
                return SizedBox();
              },
            );
          }
          return _buildActionCard(
            isSelected: isSelected,
            data: actionData[index],
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildEmptyActionView(String emptyText) {
    return DragTarget<QuickActionModel>(
      onAcceptWithDetails: (details) {},
      onAccept: (dragAction) {
        _controller.onDropAction(dragAction, null);
      },
      builder: (context, a, b) {
        return Text(
          emptyText,
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                color: ColorConstants.black,
              ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required bool isSelected,
    required QuickActionModel data,
    required BuildContext context,
  }) {
    Widget _buildActionUI({bool isDragging = false}) {
      return SizedBox(
        key: ValueKey(data.name.toString()),
        height: 100,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, right: 5),
              padding: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorConstants.secondarySeparatorColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CachedNetworkImage(
                      imageUrl: data.imageUrl,
                      fit: BoxFit.contain,
                      height: 36,
                      width: 36,
                    ),
                    SizedBox(height: 8),
                    Text(
                      data.name ?? '-',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge
                          ?.copyWith(
                            color: ColorConstants.black,
                          ),
                    )
                  ],
                ),
              ),
            ),
            if (!isDragging)
              GestureDetector(
                onTap: () {
                  _controller.updateActions(
                    data,
                    !isSelected,
                  );
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !isSelected
                          ? ColorConstants.greenAccentColor
                          : ColorConstants.errorColor,
                    ),
                    child: Center(
                      child: Icon(
                        !isSelected ? Icons.add : Icons.remove,
                        color: ColorConstants.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return DragTarget<QuickActionModel>(
      onAcceptWithDetails: (details) {},
      onAccept: (dragAction) {
        _controller.onDropAction(dragAction, data);
      },
      builder: (context, a, b) {
        return Draggable<QuickActionModel>(
          data: data,
          feedback: _buildActionUI(isDragging: true),
          child: _buildActionUI(),
        );
      },
    );
  }

  Widget _buildCTA(BuildContext context, QuickActionController controller) {
    return ActionButton(
      text: 'Done',
      showProgressIndicator:
          controller.updateActionResponse.state == NetworkState.loading,
      isDisabled: !(controller.isAnyActionUpdated &&
          controller.selectedActions.length >= 4),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      onPressed: () async {
        await controller.updateQuickAction();
        if (controller.updateActionResponse.state == NetworkState.error) {
          showToast(text: controller.updateActionResponse.message);
        }
        if (controller.updateActionResponse.state == NetworkState.loaded) {
          if (controller.updateStatus == true) {
            showToast(text: 'Actions updated successfully');
            controller.onUpdateSuccess();
          } else {
            showToast(text: 'Actions updations unsuccessful');
            controller.onClose();
          }
          AutoRouter.of(context).popForced();
        }
      },
    );
  }
}
