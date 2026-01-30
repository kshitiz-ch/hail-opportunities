// import 'package:auto_route/auto_route.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:slinky_view/slinky_view.dart';
// import 'package:wealthy/core/injection/injection.dart';
// import 'package:wealthy/core/utils/enums.dart';
// import 'package:wealthy/features/broking/features/broking_home/presentation/bloc/announcements_bloc.dart';
// import 'package:wealthy/features/broking/features/broking_home/presentation/bloc/broking_banner_detail_bloc.dart';
// import 'package:wealthy/features/broking/features/broking_home/presentation/widgets/announcements_section.dart';
// import 'package:wealthy/features/broking/features/broking_home/presentation/widgets/market_snapshot_section.dart';
// import 'package:wealthy/features/broking/features/market_snapshot/presentation/bloc/market_snapshot_bloc.dart';
// import 'package:wealthy/features/broking/features/news/presentation/bloc/market_news_bloc.dart';
// import 'package:wealthy/features/broking/features/news/presentation/bloc/stock_news_bloc.dart';
// import 'package:wealthy/features/broking/features/portfolio/presentation/bloc/holdings_bloc.dart';
// import 'package:wealthy/features/broking/features/portfolio/presentation/bloc/positions_bloc.dart';
// import 'package:wealthy/features/broking/features/research/presentation/bloc/research_list_bloc.dart';
// import 'package:wealthy/features/broking/features/screeners/presentation/bloc/screener_bloc.dart';
// import 'package:wealthy/features/broking/features/screeners/presentation/bloc/screener_categories_bloc.dart';
// import 'package:wealthy/features/broking/features/smart_value_baskets/presentation/bloc/sv_portfolio_bloc.dart';
// import 'package:wealthy/features/broking/features/smart_value_baskets/presentation/bloc/sv_portfolios_bloc.dart';
// import 'package:wealthy/features/broking/features/user_profile/presentation/bloc/broking_user_profile_bloc.dart';
// import 'package:wealthy/features/broking/features/watchlist/presentation/bloc/watchlist_bloc.dart';
// import 'package:wealthy/features/broking/features/wealthcase/presentation/bloc/wealthcase_bloc.dart';
// import 'package:wealthy/features/broking/presentation/widgets/gradient_bg_container.dart';
// import 'package:wealthy/features/home/presentation/bloc/tab_selection_cubit.dart';
// import 'package:wealthy/features/home/presentation/widgets/alert_banners.dart';
// import 'package:wealthy/features/home/presentation/widgets/kyc_header.dart';
// import 'package:wealthy/features/home/presentation/widgets/market_banners.dart';
// import 'package:wealthy/features/home/presentation/widgets/unified_home_common_widgets.dart';
// import 'package:wealthy/features/home/presentation/widgets/unified_home_overview_card.dart';
// import 'package:wealthy/features/home/presentation/widgets/unified_home_scroll_content.dart';
// import 'package:wealthy/features/home/presentation/widget/broking_kyc_loader_widget.dart';
// import 'package:wealthy/features/kyc/presentation/bloc/kyc_navigation_bloc.dart';
// import 'package:wealthy/features/notification/presentation/bloc/alert_notification_bloc.dart';
// import 'package:wealthy/features/notification/presentation/bloc/market_notification_bloc.dart';
// import 'package:wealthy/features/scheme_details/presentation/pages/horizontal_bar_chart.dart';
// import 'package:wealthy/presentation/presentation.dart';
// import 'package:wealthy/presentation/themes/broking/broking_color_scheme.dart';
// import 'package:wealthy/presentation/widgets/cards/error_container.dart';

// @RoutePage()
// class UnifiedHomePage extends StatelessWidget {
//   const UnifiedHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<MarketSnapshotBloc>(
//           create: (_) => locator<MarketSnapshotBloc>(),
//         ),
//         BlocProvider<ScreenerCategoriesBloc>(
//           create: (_) => locator<ScreenerCategoriesBloc>(),
//         ),
//         BlocProvider<WatchlistBloc>(
//           create: (_) => locator<WatchlistBloc>(),
//         ),
//         BlocProvider<BrokingBannerDetailsBloc>(
//           create: (_) => locator<BrokingBannerDetailsBloc>(),
//         ),
//         BlocProvider<ScreenerBloc>(
//           create: (_) => locator<ScreenerBloc>(),
//         ),
//         BlocProvider<AnnouncementsBloc>(
//           create: (_) => locator<AnnouncementsBloc>(),
//         ),
//         BlocProvider<StockNewsBloc>(
//           create: (_) => locator<StockNewsBloc>(),
//         ),
//         BlocProvider<MarketNewsBloc>(
//           create: (_) => locator<MarketNewsBloc>(),
//         ),
//         BlocProvider<WealthcaseBloc>(
//           create: (context) => locator<WealthcaseBloc>(),
//         ),
//         BlocProvider<SvPortfoliosBloc>(
//           create: (_) => locator<SvPortfoliosBloc>(),
//         ),
//         BlocProvider<SvPortfolioBloc>(
//           create: (_) => locator<SvPortfolioBloc>(),
//         ),
//         BlocProvider<AlertNotificationBloc>(
//           create: (_) => locator<AlertNotificationBloc>(),
//         ),
//         BlocProvider<MarketNotificationBloc>(
//           create: (_) => locator<MarketNotificationBloc>(),
//         ),
//       ],
//       child: BlocListener<KycNavigationBloc, KycNavigationState>(
//         listenWhen: (_, current) =>
//             current.maybeMap(null, loaded: (_) => true, orElse: () => false),
//         listener: (context, state) {
//           state.maybeMap(
//             null,
//             loaded: (loadedState) {
//               final brokingReady =
//                   loadedState.data.status == KycProfileStatus.INVESTMENTREADY;
//               final mfReady =
//                   loadedState.mfData.status == KycProfileStatus.INVESTMENTREADY;

//               context
//                   .read<MarketNotificationBloc>()
//                   .add(const MarketNotificationEvent.load());
//               context
//                   .read<AlertNotificationBloc>()
//                   .add(const AlertNotificationEvent.load());

//               if (brokingReady) {
//                 context
//                     .read<MarketSnapshotBloc>()
//                     .add(const MarketSnapshotEvent.load());
//                 context
//                     .read<ScreenerCategoriesBloc>()
//                     .add(const ScreenerCategoriesEvent.load());
//                 context
//                     .read<BrokingBannerDetailsBloc>()
//                     .add(const BrokingBannerDetailsEvent.checkBanner());
//                 context
//                     .read<AnnouncementsBloc>()
//                     .add(const AnnouncementsEvent.load());
//                 context.read<StockNewsBloc>().add(const StockNewsEvent.load());
//                 context
//                     .read<MarketNewsBloc>()
//                     .add(const MarketNewsEvent.load());
//                 context
//                     .read<BrokingUserProfileBloc>()
//                     .add(const BrokingUserProfileEvent.load());

//                 if (!context.read<PositionsBloc>().state.maybeWhen(
//                       () => false,
//                       loaded: (_, __, ____) => true,
//                       orElse: () => false,
//                     )) {
//                   context
//                       .read<PositionsBloc>()
//                       .add(const PositionsEvent.load());
//                 }
//                 if (!context.read<HoldingsBloc>().state.maybeWhen(
//                       () => false,
//                       loaded: (_, __, ___, ____, _____) => true,
//                       orElse: () => false,
//                     )) {
//                   context.read<HoldingsBloc>().add(const HoldingsEvent.load());
//                 }

//                 context
//                     .read<SvPortfoliosBloc>()
//                     .add(const SvPortfoliosEvent.load());
//                 context
//                     .read<WealthcaseBloc>()
//                     .add(const WealthcaseEvent.load());
//                 context.read<ResearchListBloc>().add(
//                       const ResearchListEvent.load(limit: 5),
//                     );
//                 context
//                     .read<SvPortfoliosBloc>()
//                     .add(const SvPortfoliosEvent.load());
//               }

//               if (mfReady) {
//                 // MF-specific triggers can be added here when required.
//               }
//             },
//             orElse: () {},
//           );
//         },
//         child: BlocBuilder<KycNavigationBloc, KycNavigationState>(
//           builder: (context, state) {
//             return state.when(
//               () => const BrokingKycLoaderWidget(),
//               loading: () => const BrokingKycLoaderWidget(),
//               error: (message) => ErrorContainer(
//                 message: message,
//                 onTap: () => context
//                     .read<KycNavigationBloc>()
//                     .add(const KycNavigationEvent.load('')),
//               ),
//               loaded: (brokingPrefill, mfPrefill) {
//                 final brokingReady =
//                     brokingPrefill.status == KycProfileStatus.INVESTMENTREADY;
//                 final mfReady =
//                     mfPrefill.status == KycProfileStatus.INVESTMENTREADY;

//                 return _UnifiedHomeScaffold(
//                   topContent: _resolveTopContent(
//                     brokingReady: brokingReady,
//                     mfReady: mfReady,
//                   ),
//                 );
//               },
//               noInternet: () => ErrorContainer(
//                 message: 'No Internet Connection',
//                 onTap: () => context
//                     .read<KycNavigationBloc>()
//                     .add(const KycNavigationEvent.load('')),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _resolveTopContent({
//     required bool brokingReady,
//     required bool mfReady,
//   }) {
//     // return const KycHeader();
//     if (brokingReady && mfReady) {
//       return const _ReadyTopContent();
//     } else if (mfReady) {
//       return const _MfReadyTopContent();
//     } else {
//       return const _KycPendingTopContent();
//     }
//   }
// }

// class _UnifiedHomeScaffold extends StatefulWidget {
//   const _UnifiedHomeScaffold({required this.topContent});

//   final Widget topContent;

//   @override
//   State<_UnifiedHomeScaffold> createState() => _UnifiedHomeScaffoldState();
// }

// class _UnifiedHomeScaffoldState extends State<_UnifiedHomeScaffold> {
//   final GlobalKey _topKey = GlobalKey();
//   late final SlinkyController _controller;
//   double _minSize = 0.55;

//   @override
//   void initState() {
//     super.initState();
//     _controller = SlinkyController();
//     context.read<TabSelectionCubit>().loadSelectedTab();

//     WidgetsBinding.instance.addPostFrameCallback((_) => _measureTop());
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _measureTop() {
//     final renderBox = _topKey.currentContext?.findRenderObject() as RenderBox?;
//     if (!mounted || renderBox == null) return;

//     final screenHeight = MediaQuery.of(context).size.height;
//     final topHeight = renderBox.size.height;
//     final calculated = (screenHeight - topHeight) / screenHeight;

//     setState(() {
//       _minSize = calculated.clamp(0.2, 0.7);
//     });
//     _controller.reset();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = context.themeData.extension<BrokingColorScheme>()!;
//     return Container(
//       color: colorScheme.plainBackground,
//       child: GradientBGContainer(
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           body: SafeArea(
//             bottom: false,
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           hexToColor("#FFFBF6"),
//                           hexToColor("#fff5ec"),
//                         ],
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         UnifiedHomeProfileHeader(),
//                         SizedBox(height: 50),
//                         widget.topContent,
//                         // AlertBanners()
//                       ],
//                     ),
//                   ),
//                   UnifiedHomeScrollContent()
//                 ],
//               ),
//             ),
//             // child: SlinkyView(
//             //   controller: _controller,
//             //   barrierDismissible: false,
//             //   maskColor: Colors.transparent,
//             //   panelParameter: SlinkyPanelParameter(
//             //     minSize: _minSize,
//             //     maxSize: 0.9,
//             //     appBar: const SliverAppBar(
//             //       toolbarHeight: 0,
//             //       collapsedHeight: 0,
//             //       elevation: 0,
//             //       pinned: false,
//             //       automaticallyImplyLeading: false,
//             //       backgroundColor: Colors.transparent,
//             //     ),
//             //     borderRadius: const BorderRadius.only(
//             //       topLeft: Radius.circular(24),
//             //       topRight: Radius.circular(24),
//             //     ),
//             //     contents: const [UnifiedHomeScrollContent()],
//             //   ),
//             //   body: Column(
//             //     key: _topKey,
//             //     mainAxisSize: MainAxisSize.min,
//             //     children: [
//             //       Container(
//             //         color: hexToColor("#FFFBF6"),
//             //         child: Column(
//             //           crossAxisAlignment: CrossAxisAlignment.start,
//             //           children: [
//             //             UnifiedHomeProfileHeader(),
//             //             SizedBox(height: 50),
//             //             widget.topContent,
//             //           ],
//             //         ),
//             //       ),
//             //       const SizedBox(height: 120),
//             //     ],
//             //   ),
//             // ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _KycPendingTopContent extends StatelessWidget {
//   const _KycPendingTopContent();

//   @override
//   Widget build(BuildContext context) {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         UnifiedHomeProfileHeader(),
//         SizedBox(height: 16),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: UnifiedHomeKycBanner(
//             title: 'Complete your KYC',
//             description: 'Start your Wealth journey today',
//           ),
//         ),
//         SizedBox(height: 16),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: AnnouncementsSection(),
//         ),
//       ],
//     );
//   }
// }

// class _MfReadyTopContent extends StatelessWidget {
//   const _MfReadyTopContent();

//   @override
//   Widget build(BuildContext context) {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         UnifiedHomeProfileHeader(),
//         SizedBox(height: 16),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: UnifiedHomeKycBanner(
//             title: 'Stocks KYC pending',
//             description: 'Finish broking KYC to trade equities',
//           ),
//         ),
//         SizedBox(height: 16),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: AnnouncementsSection(),
//         ),
//       ],
//     );
//   }
// }

// class _ReadyTopContent extends StatelessWidget {
//   const _ReadyTopContent();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: hexToColor('#FFFBF6'),
//       // decoration: BoxDecoration(
//       //   gradient:
//       // ),
//       child: const Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // UnifiedHomeProfileHeader(),
//           // SizedBox(height: 16),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: MarketSnapshotSection(),
//           ),
//           // SizedBox(height: 16),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 0),
//             child: UnifiedHomeOverviewCard(),
//           ),
//           SizedBox(height: 16),
//           // Padding(
//           //   padding: EdgeInsets.symmetric(horizontal: 20),
//           //   child: AnnouncementsSection(),
//           // ),
//         ],
//       ),
//     );
//   }
// }
