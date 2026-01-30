// import 'package:flutter/material.dart';
// import 'package:wealthy/core/injection/injection.dart';
// import 'package:wealthy/features/broking/features/broking_home/presentation/widgets/home_search_card.dart';
// import 'package:wealthy/features/broking/features/broking_home/presentation/widgets/investment_ideas_section.dart';
// import 'package:wealthy/features/broking/features/broking_home/presentation/widgets/investment_products_section.dart';
// import 'package:wealthy/features/broking/features/broking_home/presentation/widgets/news_section.dart';
// import 'package:wealthy/features/broking/features/watchlist/presentation/bloc/watchlist_bloc.dart';
// import 'package:wealthy/features/home/presentation/widgets/alert_banners.dart';
// import 'package:wealthy/features/home/presentation/widgets/market_banners.dart';
// import 'package:wealthy/presentation/injection/constants.dart';
// import 'package:wealthy/presentation/navigation/app_router.dart';
// import 'package:wealthy/presentation/navigation/app_router.gr.dart';
// import 'package:wealthy/presentation/presentation.dart';
// import 'package:wealthy/presentation/themes/broking/broking_color_scheme.dart';
// import 'package:wealthy/presentation/themes/broking/broking_text_style.dart';

// class UnifiedHomeScrollContent extends StatelessWidget {
//   const UnifiedHomeScrollContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = context.themeData.extension<BrokingColorScheme>()!;

//     return Container(
//       color: Colors.white,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: const [
//           // _UnifiedSearchBar(),
//           // SizedBox(height: 16),
//           // AlertBanners(),

//           SizedBox(height: 16),
//           _UnifiedSearchBar(),
//           SizedBox(height: 16),
//           Divider(height: 1, thickness: 1),
//           SizedBox(height: 16),
//           SizedBox(height: 24),
//           _WealthSignalsSection(),
//           SizedBox(height: 32),
//           InvestmentProductsSection(),
//           SizedBox(height: 32),
//           MarketBanners(),
//           SizedBox(height: 24),
//           NewsSection(),
//           SizedBox(height: 48),
//         ],
//       ),
//     );

//     return SliverToBoxAdapter(
//       child: Container(
//         decoration: BoxDecoration(
//           color: colorScheme.plainBackground,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(24),
//             topRight: Radius.circular(24),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 16,
//               offset: const Offset(0, -4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: const [
//             _UnifiedSearchBar(),
//             SizedBox(height: 16),
//             AlertBanners(),
//             MarketBanners(),
//             // SizedBox(height: 16),
//             // _UnifiedSearchBar(),
//             // SizedBox(height: 16),
//             // Divider(height: 1, thickness: 1),
//             // SizedBox(height: 16),
//             // SizedBox(height: 24),
//             // _WealthSignalsSection(),
//             // SizedBox(height: 32),
//             // InvestmentProductsSection(),
//             // SizedBox(height: 32),
//             // SizedBox(height: 24),
//             // NewsSection(),
//             // SizedBox(height: 48),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _UnifiedSearchBar extends StatelessWidget {
//   const _UnifiedSearchBar();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: HomeSearchCard(
//         hint: 'Search for Stocks & Mutual Funds',
//         onPressed: () {
//           locator<AppRouter>().push(
//             SearchPageRoute(
//               watchlistBloc: locator<WatchlistBloc>(),
//               onHomePage: true,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _WealthSignalsSection extends StatelessWidget {
//   const _WealthSignalsSection();

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = context.themeData.extension<BrokingColorScheme>()!;
//     final style = context.themeData.extension<BrokingTextStyle>()!;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Image.asset(AssetsFiles.wealthSignals, height: 44),
//               const SizedBox(width: 10),
//               Text('Wealth Signals',
//                   style: style.headline3.copyWith(height: 1)),
//               const Spacer(),
//               InkWell(
//                 onTap: () {
//                   locator<AppRouter>().push(const ResearchIdeasPageRoute());
//                 },
//                 child: Text(
//                   'View All',
//                   style: style.bodySmall.copyWith(
//                     fontSize: 11,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 280 * MediaQuery.of(context).textScaler.scale(1).toDouble(),
//           child: const InvestmentIdeasSection(),
//         ),
//       ],
//     );
//   }
// }
