import 'package:home_service_user/component/view_all_label_component.dart';
import 'package:home_service_user/main.dart';
import 'package:home_service_user/model/category_model.dart';
import 'package:home_service_user/screens/category/category_screen.dart';
import 'package:home_service_user/screens/dashboard/component/category_widget.dart';
import 'package:home_service_user/screens/service/view_all_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryComponent extends StatefulWidget {
  final List<CategoryData>? categoryList;

  CategoryComponent({this.categoryList});

  @override
  CategoryComponentState createState() => CategoryComponentState();
}

class CategoryComponentState extends State<CategoryComponent> {

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = screenWidth / 4;
    double itemHeight = 60;

    if (widget.categoryList.validate().isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ViewAllLabel(
          label: language.category,
          list: widget.categoryList!,
          labelSize:18,
          onTap: () {
            CategoryScreen().launch(context).then((value) {
              setStatusBarColor(Colors.transparent);
            });
          },
        ).paddingSymmetric(horizontal: 16),
        /* HorizontalList(
          itemCount: widget.categoryList.validate().length+4,// change
          padding: EdgeInsets.only(left: 16, right: 16),
          runSpacing: 8,
          spacing: 12,
          itemBuilder: (_, i) {
            CategoryData data = i>3?widget.categoryList![0]:widget.categoryList![i]; // change
            return GestureDetector(
              onTap: () {
                ViewAllServiceScreen(categoryId: data.id.validate(), categoryName: data.name, isFromCategory: true).launch(context);
              },
              child: CategoryWidget(categoryData: data),
            );
          },
        ),*/

        /*Container(
          height: 200, // Adjust height based on content
          width: MediaQuery.of(context).size.width,

          child: GridView.builder(
           // padding: EdgeInsets.only(left: 16, right: 16),
            scrollDirection: Axis.horizontal, // Maintain horizontal scroll
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:80, // 2 rows
              mainAxisSpacing: 25, // Vertical spacing between rows
              crossAxisSpacing: 21, // Horizontal spacing between columns
              childAspectRatio: itemWidth / itemHeight, // Adjust based on design needs
            ),
            itemCount: widget.categoryList.validate().length+4,
            itemBuilder: (_, i) {
              CategoryData data = i>3? widget.categoryList![0]:widget.categoryList![i];

              return GestureDetector(
                onTap:() {
                  ViewAllServiceScreen(
                    categoryId: data.id.validate(),
                    categoryName: data.name,
                    isFromCategory: true,
                  ).launch(context);
                },
                child: CategoryWidget(categoryData: data)
              );
            },
          ),
        ),*/

        Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double desiredItemsInView = screenWidth <= 330 ? 3 : screenWidth <= 355 ? 3.5 : 4;
              double itemWidth = screenWidth / desiredItemsInView;
              double itemHeight = 80;
              int totalItems = widget.categoryList.validate().length ;

              // Calculate total content width of all items + spacing between them
              double totalContentWidth = totalItems * 71 + (totalItems - 1) * 21;

              // Padding to center if total content is less than screen width
              double horizontalPadding = (screenWidth - totalContentWidth) / 2;
              horizontalPadding = horizontalPadding < 0 ? 0 : horizontalPadding;

              return GridView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 80,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 21,
                  childAspectRatio: itemWidth / itemHeight,
                ),
                itemCount: totalItems,
                itemBuilder: (_, i) {
                  CategoryData data = widget.categoryList![i];/*i > 3
                      ? widget.categoryList![0]
                      : widget.categoryList![i];*/

                  return GestureDetector(
                    onTap: () {

                      ViewAllServiceScreen(
                        categoryId: data.id.validate(),
                        categoryName: data.name,
                        isFromCategory: true,
                      ).launch(context);
                    },
                    child: CategoryWidget(categoryData: data),
                  );
                },
              );
            },
          ),
        ),

      ],
    );
  }
}
