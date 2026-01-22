import 'package:home_service_user/component/cached_image_widget.dart';
import 'package:home_service_user/main.dart';
import 'package:home_service_user/screens/blog/model/blog_response_model.dart';
import 'package:home_service_user/screens/blog/view/blog_detail_screen.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/image_border_component.dart';

class BlogItemComponent extends StatefulWidget {
  final BlogData? blogData;

  BlogItemComponent({this.blogData});

  @override
  State<BlogItemComponent> createState() => _BlogItemComponentState();
}

class _BlogItemComponentState extends State<BlogItemComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        BlogDetailScreen(blogId: widget.blogData!.id.validate()).launch(context);
      },
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.all(9),
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: radius(),
            backgroundColor: cardColor,
        //    border: appStore.isDarkMode ? Border.all(color: context.dividerColor) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedImageWidget(
                url: widget.blogData!.imageAttachments.validate().isNotEmpty ? widget.blogData!.imageAttachments!.first.validate() : '',
                fit: BoxFit.cover,
                height: 39,
                width: 39,
                radius: 2,
              ),
              14.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 157,
                        child: Text(
                          widget.blogData!.title.validate(),
                          style: boldTextStyle(size: 16, weight: FontWeight.w600,color: pureBlack, fontFamily: GoogleFonts.mulish().fontFamily),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                        Text(widget.blogData!.publishDate.validate(), style: secondaryTextStyle(size: 10, weight: FontWeight.w400, fontFamily: GoogleFonts.mulish().fontFamily, color: greyBFBFBF)),
                    ],
                  ),
              //    6.height,
                  Row(
                    children: [
                      Row(
                        children: [
                          ImageBorder(
                            src: widget.blogData!.authorImage.validate(),
                            height: 15,
                          ),
                          8.width,
                          Text(widget.blogData!.authorName.validate(), style: primaryTextStyle(size: 14,
                          fontFamily: GoogleFonts.mulish().fontFamily,
                           color: grey636D77,
                           weight: FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis).expand(),
                        ],
                      ).expand(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.remove_red_eye_outlined, size: 14, color: context.iconColor),
                          4.width,
                          Text('${widget.blogData!.totalViews.validate()} ', style: secondaryTextStyle()),
                          Text(language.views, style: secondaryTextStyle(size: 10, weight: FontWeight.w400, fontFamily: GoogleFonts.mulish().fontFamily, color:  grey636D77
        ), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      )
                    ],
                  ),
                ],
              ).expand(),
            ],
          ),
        ),
      ),
    );
  }
}
