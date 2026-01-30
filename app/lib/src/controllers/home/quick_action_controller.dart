import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:core/modules/advisor/models/quick_action_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class QuickActionController extends GetxController {
  bool isAnyActionUpdated = false;

  List<QuickActionModel> selectedActions = [];
  List<QuickActionModel> unselectedActions = [];
  List<QuickActionModel> updatedSelectedActions = [];
  List<QuickActionModel> updatedUnselectedActions = [];

  bool? updateStatus;

  ApiResponse fetchActionResponse = ApiResponse();
  ApiResponse updateActionResponse = ApiResponse();

  final int maxAllowedActions = 12, minAllowedActions = 4;

  final commonController = Get.find<CommonController>();

  @override
  Future<void> onInit() async {
    super.onInit();
    getQuickActions();
  }

  Future<void> getQuickActions() async {
    // remove revenue sheet, payout, myteam in app for all employees
    final isNonEmployee = !isEmployeeLoggedIn();

    final isPortfolioReviewEnabled =
        commonController.portfolioReviewSectionFlag.value;

    void updateActionList({
      required dynamic actionJson,
      required Function(QuickActionModel) onAdd,
    }) {
      final action = QuickActionModel.fromJson(actionJson);

      // Hide Portfolio Review action if feature flag is disabled
      if (action.name == 'Portfolio Review' && !isPortfolioReviewEnabled) {
        return;
      }

      if (['Revenue Sheet', 'Payout', 'My Office'].contains(action.name)) {
        if (isNonEmployee) {
          onAdd(action);
        }
      } else {
        onAdd(action);
      }
    }

    fetchActionResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey() ?? '';

      final QueryResult response =
          await AdvisorRepository().getQuickActions(apiKey);
      if (!response.hasException) {
        selectedActions = [];
        unselectedActions = [];

        WealthyCast.toList(response.data!['hydra']['actions']['customActions'])
            .forEach((actionJson) {
          updateActionList(
              actionJson: actionJson,
              onAdd: (action) {
                selectedActions.add(action);
              });
        });

        WealthyCast.toList(response.data!['hydra']['actions']['defaultActions'])
            .forEach((actionJson) {
          updateActionList(
              actionJson: actionJson,
              onAdd: (action) {
                unselectedActions.add(action);
              });
        });

        updatedSelectedActions = List.from(selectedActions);
        updatedUnselectedActions = List.from(unselectedActions);
        fetchActionResponse.state = NetworkState.loaded;
      } else {
        fetchActionResponse.message =
            response.exception!.graphqlErrors[0].message;
        fetchActionResponse.state = NetworkState.error;
      }
    } catch (error) {
      fetchActionResponse.state = NetworkState.error;
      fetchActionResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> updateQuickAction() async {
    updateActionResponse.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = {};
      payload['numActions'] = selectedActions.length;
      payload['actions'] = List<Map>.generate(
        selectedActions.length,
        (index) => {
          'actionId': selectedActions[index].id,
          'customOrder': index + 1,
        },
      );
      final QueryResult response =
          await AdvisorRepository().updateQuickActions(apiKey, payload);
      if (!response.hasException) {
        updateStatus =
            WealthyCast.toBool(response.data!['updateActions']['success']);
        updateActionResponse.state = NetworkState.loaded;
      } else {
        updateActionResponse.message =
            response.exception!.graphqlErrors[0].message;
        updateActionResponse.state = NetworkState.error;
      }
    } catch (error) {
      updateActionResponse.state = NetworkState.error;
      updateActionResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  void updateActions(QuickActionModel action, bool isSelected) {
    // isSelected true move from unselected to selected
    // & vice versa

    if (isSelected) {
      // if count exceeds max length pop last element to other section
      QuickActionModel? removedAction;
      if (selectedActions.length == maxAllowedActions) {
        removedAction = selectedActions.removeLast();
      }
      unselectedActions.remove(action);
      selectedActions.add(action);
      if (removedAction != null) {
        unselectedActions.add(removedAction);
      }
    } else {
      selectedActions.remove(action);
      unselectedActions.add(action);
    }
    isAnyActionUpdated = true;
    update();
  }

  void reorderActions(int oldIndex, int newIndex, bool isSelected) {
    // swap old index and new index
    if (isSelected) {
      final tempAction = selectedActions[oldIndex];
      selectedActions[oldIndex] = selectedActions[newIndex];
      selectedActions[newIndex] = tempAction;
    } else {
      final tempAction = unselectedActions[oldIndex];
      unselectedActions[oldIndex] = unselectedActions[newIndex];
      unselectedActions[newIndex] = tempAction;
    }
    isAnyActionUpdated = true;
    update();
  }

  void onDropAction(
    QuickActionModel dragAction,
    QuickActionModel? dropAction,
  ) {
    final dragSelectedActionIndex =
        selectedActions.indexWhere((element) => element.id == dragAction.id);
    final dropSelectedActionIndex =
        selectedActions.indexWhere((element) => element.id == dropAction?.id);
    final dragUnselectedActionIndex =
        unselectedActions.indexWhere((element) => element.id == dragAction.id);
    final dropUnselectedActionIndex =
        unselectedActions.indexWhere((element) => element.id == dropAction?.id);

    if (dropAction == null) {
      // action dropped to empty space from selected to unselected
      if (dragSelectedActionIndex != -1) {
        return updateActions(dragAction, false);
      }
      // action dropped to empty space from unselected to selected
      if (dragUnselectedActionIndex != -1) {
        return updateActions(dragAction, true);
      }
    }

    if (dropSelectedActionIndex >= 0 && dragSelectedActionIndex >= 0) {
      // both drag and drop action in same selected section
      return reorderActions(
          dragSelectedActionIndex, dropSelectedActionIndex, true);
      // reorder
    }
    if (dragUnselectedActionIndex >= 0 && dropUnselectedActionIndex >= 0) {
      // both drag and drop action in same unselected section
      return reorderActions(
          dragUnselectedActionIndex, dropUnselectedActionIndex, false);
      // reorder
    }
    if (dropSelectedActionIndex >= 0 && dragUnselectedActionIndex >= 0) {
      // action moved from unselected to selected

      // insert drag item at drop index
      selectedActions.insert(dropSelectedActionIndex,
          unselectedActions.removeAt(dragUnselectedActionIndex));
      // if length > maxAllowedActions
      if (selectedActions.length > maxAllowedActions) {
        final lastAction = selectedActions.removeLast();
        if (dragUnselectedActionIndex < unselectedActions.length) {
          unselectedActions.insert(dragUnselectedActionIndex, lastAction);
        } else {
          unselectedActions.add(lastAction);
        }
      }
      isAnyActionUpdated = true;
      update();
      return;
    }
    if (dropUnselectedActionIndex >= 0 && dragSelectedActionIndex >= 0) {
      // action moved from selected to unselected
      return updateActions(dragAction, false);
    }
  }

  void onUpdateSuccess() {
    updatedSelectedActions = List.from(selectedActions);
    updatedUnselectedActions = List.from(unselectedActions);
    isAnyActionUpdated = false;
    getQuickActions();
  }

  void onClose() {
    selectedActions = List.from(updatedSelectedActions);
    unselectedActions = List.from(updatedUnselectedActions);
    isAnyActionUpdated = false;
    update();
  }
}
