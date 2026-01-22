
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/cached_image_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../component/loader_widget.dart';
import '../../main.dart';
import '../../model/category_model.dart';
import '../../model/service_data_model.dart';
import '../../network/rest_apis.dart';
import '../../store/filter_store.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../utils/images.dart';
import '../filter/filter_screen.dart';
import 'component/service_component.dart';

class ViewAllServiceScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final String isFeatured;
  final bool isFromProvider;
  final bool isFromCategory;
  final int? providerId;
  final String? categoryDescription;

  ViewAllServiceScreen({
    this.categoryId,
    this.categoryName = '',
    this.isFeatured = '',
    this.isFromProvider = true,
    this.isFromCategory = false,
    this.providerId,
    this.categoryDescription ="",
    Key? key,
  }) : super(key: key);

  @override
  State<ViewAllServiceScreen> createState() => _ViewAllServiceScreenState();
}

class _ViewAllServiceScreenState extends State<ViewAllServiceScreen> {
  Future<List<CategoryData>>? futureCategory;
  List<CategoryData> categoryList = [];

  Future<List<ServiceData>>? futureService;
  List<ServiceData> serviceList = [];

  FocusNode myFocusNode = FocusNode();
  TextEditingController searchCont = TextEditingController();

  int? subCategory;

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
    filterStore = FilterStore();
  }

  void init() async {
    fetchAllServiceData();

    if (widget.categoryId != null) {
      fetchCategoryList();
    }
  }

  void fetchCategoryList() async {
    futureCategory = getSubCategoryListAPI(catId: widget.categoryId!);
  }

  void fetchAllServiceData() async {
    futureService = searchServiceAPI(
      page: page,
      list: serviceList,
      categoryId: widget.categoryId != null ? widget.categoryId.validate().toString() : filterStore.categoryId.join(','),
      subCategory: subCategory != null ? subCategory.validate().toString() : '',
      providerId: widget.providerId != null ? widget.providerId.toString() : filterStore.providerId.join(","),
      isPriceMin: filterStore.isPriceMin,
      isPriceMax: filterStore.isPriceMax,
      ratingId: filterStore.ratingId.join(','),
      search: searchCont.text,
      latitude: filterStore.latitude,
      longitude: filterStore.longitude,
      lastPageCallBack: (p0) {
        isLastPage = p0;
      },
      isFeatured: widget.isFeatured,
    );
  }

  String get setSearchString {
    if (!widget.categoryName.isEmptyOrNull) {
      return widget.categoryName!;
    } else if (widget.isFeatured == "1") {
      return language.lblFeatured;
    } else {
      return language.allServices;
    }
  }

  Widget subCategoryWidget() {
    return SnapHelperWidget<List<CategoryData>>(
      future: futureCategory,
      initialData: cachedSubcategoryList.firstWhere((element) => element?.$1 == widget.categoryId.validate(), orElse: () => null)?.$2,
      loadingWidget: Offstage(),
      onSuccess: (list) {
        if (list.length == 1) return Offstage();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            16.height,
            Text(language.lblSubcategories, style: boldTextAutoStyle(context:context,size: LABEL_TEXT_SIZE,weight: FontWeight.w700,commonColor: Colors.black, fontFamily: GoogleFonts.mulish().fontFamily)).paddingLeft(16),
            HorizontalList(
              itemCount: list.validate().length,
              padding: EdgeInsets.only(left: 16, right: 16),
              runSpacing: 8,
              spacing: 12,
              itemBuilder: (_, index) {
                CategoryData data = list[index];

                return Observer(
                  builder: (_) {
                    bool isSelected = filterStore.selectedSubCategoryId == index;

                    return GestureDetector(
                      onTap: () {
                        filterStore.setSelectedSubCategory(catId: index);

                        subCategory = data.id;
                        page = 1;

                        appStore.setLoading(true);
                        fetchAllServiceData();

                        setState(() {});
                      },
                      child: SizedBox(
                        width: context.width() / 4 - 20,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              children: [
                                16.height,
                                if (index == 0)
                                  Container(
                                    height: CATEGORY_ICON_SIZE,
                                    width: CATEGORY_ICON_SIZE,
                                    decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, border: Border.all(color: grey8E8E8)),
                                    alignment: Alignment.center,
                                    child: Text(data.name.validate(), style: boldTextStyle(size: 18,weight: FontWeight.w800, fontFamily: GoogleFonts.mulish().fontFamily,color: blue326A7F)),
                                  ),
                                if (index != 0)
                                  data.categoryImage.validate().endsWith('.svg')
                                      ? Container(
                                          width: CATEGORY_ICON_SIZE,
                                          height: CATEGORY_ICON_SIZE,
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(color: grey8E8E8,border: Border.all(color: grey8E8E8), shape: BoxShape.circle),
                                          child: SvgPicture.network(
                                            data.categoryImage.validate(),
                                            height: CATEGORY_ICON_SIZE,
                                            width: CATEGORY_ICON_SIZE,
                                            color: appStore.isDarkMode ?data.color.validate(value: '000').toColor()/* Colors.white */: data.color.validate(value: '000').toColor(),
                                            placeholderBuilder: (context) => PlaceHolderWidget(height: CATEGORY_ICON_SIZE, width: CATEGORY_ICON_SIZE, color: transparentColor),
                                          ),
                                        )
                                      : Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: white,border: Border.all(color: grey8E8E8), shape: BoxShape.circle),
                                          child: CachedImageWidget(
                                            url: data.categoryImage.validate(),
                                            fit: BoxFit.fitWidth,
                                            width: SUBCATEGORY_ICON_SIZE,
                                            height: SUBCATEGORY_ICON_SIZE,
                                            circle: true,
                                          ),
                                        ),
                                4.height,
                                if (index == 0) Container(width:50,child: Text(language.lblViewAll, style: boldTextAutoStyle(context:context,commonColor: Colors.black,size: 13,weight: FontWeight.w600, fontFamily: GoogleFonts.mulish().fontFamily), textAlign: TextAlign.center, maxLines: 2)),
                                if (index != 0) Text('${data.name.validate()}', style: boldTextAutoStyle(context:context,commonColor: Colors.black,size: 13,weight: FontWeight.w600, fontFamily: GoogleFonts.mulish().fontFamily), textAlign: TextAlign.center, maxLines: 2,),
                              ],
                            ),
                            Positioned(
                              top: 14,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: boxDecorationDefault(color: primaryColor),
                                child: Icon(Icons.done, size: 16, color: Colors.white),
                              ).visible(isSelected),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            16.height,
          ],
        );
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    filterStore.clearFilters();
    myFocusNode.dispose();
    filterStore.setSelectedSubCategory(catId: 0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: setSearchString,

      child: Container(
        color: Colors.white,
        height: context.height(),
        width: context.width(),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  AppTextField(
                    textFieldType: TextFieldType.OTHER,
                    focus: myFocusNode,
                    controller: searchCont,
                    cursorColor: primaryColor,
                    suffix: CloseButton(
                      onPressed: () {
                        page = 1;
                        searchCont.clear();
                        filterStore.setSearch('');

                        appStore.setLoading(true);
                        fetchAllServiceData();
                        setState(() {});
                      },
                    ).visible(searchCont.text.isNotEmpty),
                    onFieldSubmitted: (s) {
                      page = 1;

                      filterStore.setSearch(s);
                      appStore.setLoading(true);

                      fetchAllServiceData();
                      setState(() {});
                    },
                    decoration: inputDecoration(context).copyWith(
                      hintText: "${language.lblSearchFor} $setSearchString",
                      prefixIcon: search_no_bg.iconSvgImage(color:black999999,size: 14).paddingAll(18),
                      hintStyle: secondaryTextStyle(size: 14,weight: FontWeight.w500, fontFamily: GoogleFonts.mulish().fontFamily,color: black999999),
                    ),
                    textStyle:secondaryTextStyle(size: 14,weight: FontWeight.w500, fontFamily: GoogleFonts.mulish().fontFamily,color: black999999),
                  ).expand(),
                  16.width,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                    decoration: boxDecorationDefault(color: primaryColor),
                    child: ic_filter_bar.iconImageVariable(color: white, height: 13,width: 24),
                  ).onTap(() {
                    hideKeyboard(context);

                    FilterScreen(isFromProvider: widget.isFromProvider, isFromCategory: widget.isFromCategory).launch(context).then((value) {
                      if (value != null) {
                        page = 1;
                        appStore.setLoading(true);

                        fetchAllServiceData();
                        setState(() {});
                      }
                    });
                  }, borderRadius: radius())
                ],
              ),
            ),
            AnimatedScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              onSwipeRefresh: () {
                page = 1;
                appStore.setLoading(true);
                fetchAllServiceData();
                setState(() {});

                return Future.value(false);
              },
              onNextPage: () {
                if (!isLastPage) {
                  page++;

                  appStore.setLoading(true);
                  fetchAllServiceData();
                  setState(() {});
                }
              },
              children: [
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    language.hintDescription,
                    style: boldTextAutoStyle(context:context,size: LABEL_TEXT_SIZE,weight: FontWeight.w700,commonColor: Colors.black, fontFamily: GoogleFonts.mulish().fontFamily),
                    textAlign: TextAlign.start,
                  ).visible(widget.categoryDescription.validate().isNotEmpty),
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.categoryDescription??"",
                    style: secondaryTextStyle(size: 16),
                    textAlign: TextAlign.start,
                  ).visible(widget.categoryDescription.validate().isNotEmpty),
                ),
                if (widget.categoryDescription.validate().isNotEmpty)
                16.height,
                if (widget.categoryId != null) subCategoryWidget(),
                16.height,
                SnapHelperWidget(
                  future: futureService,
                  loadingWidget: LoaderWidget(),
                  errorBuilder: (p0) {
                    return NoDataWidget(
                      title: p0,
                      retryText: language.reload,
                      imageWidget: ErrorStateWidget(),
                      onRetry: () {
                        page = 1;
                        appStore.setLoading(true);

                        fetchAllServiceData();
                        setState(() {});
                      },
                    );
                  },
                  onSuccess: (data) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.service, style: boldTextStyle(size: LABEL_TEXT_SIZE,weight: FontWeight.w700, fontFamily: GoogleFonts.mulish().fontFamily,color:blue06324F )).paddingSymmetric(horizontal: 16),
                        AnimatedListView(
                          itemCount: serviceList.length,
                          listAnimationType: ListAnimationType.FadeIn,
                          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          emptyWidget: NoDataWidget(
                            title: language.lblNoServicesFound,
                            subTitle: (searchCont.text.isNotEmpty || filterStore.providerId.isNotEmpty || filterStore.categoryId.isNotEmpty) ? language.noDataFoundInFilter : null,
                            imageWidget: EmptyStateWidget(),
                          ),
                          itemBuilder: (_, index) {
                            return ServiceComponent(serviceData: serviceList[index]).paddingAll(8);
                          },
                        ).paddingAll(8),
                      ],
                    );
                  },
                ),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
