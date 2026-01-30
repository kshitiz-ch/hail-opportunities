import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';

/// Guard to redirect specific insurance product variants to the generate quotes screen
class InsuranceRedirectGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Get the route being navigated to
    final route = resolver.route;

    // Check if this is an InsuranceDetailRoute
    if (route.name == InsuranceDetailRoute.name) {
      // Access route arguments
      final args = route.args as InsuranceDetailRouteArgs?;

      final productVariant = args?.productVariant ??
          route.params.optString('productVariant') ??
          args?.insuranceData?.productVariant?.toString().toLowerCase();

      // Redirect TERM, SAVINGS, and HEALTH variants to generate quotes screen
      if (productVariant == InsuranceProductVariant.TERM ||
          productVariant == InsuranceProductVariant.SAVINGS ||
          productVariant == InsuranceProductVariant.HEALTH) {
        // Redirect to InsuranceGenerateQuotesRoute with the same parameters
        resolver.redirectUntil(
          InsuranceGenerateQuotesRoute(
            productVariant: productVariant,
            insuranceData: args?.insuranceData,
            selectedClient: args?.selectedClient,
          ),
        );
        return;
      }
    }

    // Allow navigation to proceed for other variants
    resolver.next(true);
  }
}
