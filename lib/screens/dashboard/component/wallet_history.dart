
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/extensions/num_extenstions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/base_scaffold_widget.dart';
import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../../../main.dart';
import '../../../model/user_wallet_history.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import 'wallet_history_shimmer.dart';

class UserWalletHistoryScreen extends StatefulWidget {
  const UserWalletHistoryScreen({Key? key}) : super(key: key);

  @override
  State<UserWalletHistoryScreen> createState() => _UserWalletHistoryScreenState();
}

class _UserWalletHistoryScreenState extends State<UserWalletHistoryScreen> {
  Future<List<WalletDataElement>>? future;

  List<WalletDataElement> walletHistoryList = [];
  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getUserWalletHistory(
      page,
      walletDataList: walletHistoryList,
      lastPageCallBack: (p) {
        isLastPage = p;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.walletHistory,
      
      showLoader: false,
      child: Stack(
        children: [
          SnapHelperWidget<List<WalletDataElement>>(
            initialData: cachedWalletHistoryList,
            future: future,
            loadingWidget: WalletHistoryShimmer(),
            onSuccess: (snap) {
              return AnimatedListView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(8),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemCount: snap.length,
                emptyWidget: NoDataWidget(title: language.noDataAvailable, imageWidget: EmptyStateWidget()),
                shrinkWrap: true,
                onNextPage: () {
                  if (!isLastPage) {
                    page++;

                    init();
                    setState(() {});
                  }
                },
                onSwipeRefresh: () async {
                  page = 1;
                  init();
                  setState(() {});
                  return await 2.seconds.delay;
                },
                disposeScrollController: true,
                itemBuilder: (BuildContext context, index) {
                  return Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(),
                      backgroundColor: context.cardColor,
                      border: appStore.isDarkMode ? Border.all(color: context.dividerColor) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          // padding: EdgeInsets.all(8),
                          // decoration: BoxDecoration(
                          //   shape: BoxShape.circle,
                          //   color: snap[index].activityType.toLowerCase().contains(PAYMENT_STATUS_PAID) ? Colors.red.shade50 : Colors.green.shade50,
                          // ),
                          child: SvgPicture.asset(
                            snap[index].activityType.toLowerCase().contains(PAYMENT_STATUS_PAID) ? ic_diagonal_right_up_arrow : ic_diagonal_left_down_arrow,
                            height: 30,
                            width: 30,
                            color: snap[index].activityType.toLowerCase().contains(PAYMENT_STATUS_PAID) ? Colors.red : Colors.green,
                          ),
                        ),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (snap[index].activityData != null)
                                  Text(
                                    snap[index].activityType.toLowerCase().contains(PAYMENT_STATUS_PAID) ? language.debit : language.credit,
                                    style: boldTextStyle(fontFamily: GoogleFonts.mulish().fontFamily,
                                    color: pureBlack,
                                    weight: FontWeight.w600,size: 16),
                                  ),
                                Text(formatDate(snap[index].datetime), style: secondaryTextStyle(fontFamily: GoogleFonts.mulish().fontFamily,
                                size: 10,
                                weight: FontWeight.w400), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  snap[index].activityMessage,
                                  style: boldTextStyle(size: 14, weight: FontWeight.w400,
                                  color: grey636D77, fontFamily: GoogleFonts.mulish().fontFamily,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ).expand(),
                                Text(
                                  snap[index].activityData!.creditDebitAmount.validate().toPriceFormat(),
                                  style: boldTextStyle(color: snap[index].activityType.toLowerCase().contains(PAYMENT_STATUS_PAID) ? Colors.redAccent : Colors.green,
                                  fontFamily: GoogleFonts.mulish().fontFamily,
                                  size: 10,
                                  weight: FontWeight.w700),
                                ),
                              ],
                            ),
                            2.height,
                          ],
                        ).expand(),
                      ],
                    ),
                  );
                },
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading && page != 1)),
        ],
      ),
    );
  }
}
