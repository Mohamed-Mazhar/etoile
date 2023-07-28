import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/cart_model.dart';
import 'package:flutter_restaurant/data/model/response/category_model.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/banner_provider.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/category_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/theme_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/title_widget.dart';
import 'package:flutter_restaurant/view/screens/home/widget/cart_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerView extends StatefulWidget {
  const BannerView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<BannerView> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (context, banner, child) {
        return banner.bannerList != null
            ? banner.bannerList!.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 0, 10),
                        child: TitleWidget(title: getTranslated('banner', context)),
                      ),
                      Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          CarouselSlider.builder(
                            carouselController: _controller,
                            itemCount: banner.bannerList?.length,
                            options: CarouselOptions(
                              autoPlay: true,
                              autoPlayAnimationDuration: const Duration(seconds: 2),
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              },
                              viewportFraction: 1.0,
                              aspectRatio: 2.5,
                              enableInfiniteScroll: false,
                            ),
                            itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                              return Consumer<CartProvider>(builder: (context, cartProvider, child) {
                                return GestureDetector(
                                  onTap: () {
                                    if (banner.bannerList![itemIndex].productId != null) {
                                      Product? product;
                                      for (Product prod in banner.productList) {
                                        if (prod.id == banner.bannerList![itemIndex].productId) {
                                          product = prod;
                                          break;
                                        }
                                      }
                                      if (product != null) {
                                        ResponsiveHelper.isMobile()
                                            ? showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                builder: (con) => CartBottomSheet(
                                                  product: product,
                                                  callback: (CartModel cartModel) {
                                                    showCustomSnackBar(
                                                        getTranslated('added_to_cart', context),
                                                        isError: false);
                                                  },
                                                ),
                                              )
                                            : showDialog(
                                                context: context,
                                                builder: (con) => Dialog(
                                                      backgroundColor: Colors.transparent,
                                                      child: CartBottomSheet(
                                                        product: product,
                                                        callback: (CartModel cartModel) {
                                                          showCustomSnackBar(
                                                              getTranslated('added_to_cart', context),
                                                              isError: false);
                                                        },
                                                      ),
                                                    ));
                                      }
                                    } else if (banner.bannerList![itemIndex].categoryId != null) {
                                      CategoryModel? category;
                                      for (CategoryModel categoryModel
                                          in Provider.of<CategoryProvider>(context, listen: false)
                                              .categoryList!) {
                                        if (categoryModel.id == banner.bannerList![itemIndex].categoryId) {
                                          category = categoryModel;
                                          break;
                                        }
                                      }
                                      if (category != null) {
                                        Navigator.pushNamed(context, Routes.getCategoryRoute(category));
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsetsDirectional.only(start: 12, end: 12),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[
                                              Provider.of<ThemeProvider>(context).darkTheme ? 900 : 300]!,
                                          blurRadius: Provider.of<ThemeProvider>(context).darkTheme ? 2 : 5,
                                          spreadRadius: Provider.of<ThemeProvider>(context).darkTheme ? 0 : 1,
                                        )
                                      ],
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: Images.placeholderBanner,
                                        fit: BoxFit.fill,
                                        image:
                                            '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${banner.bannerList![itemIndex].image}',
                                        imageErrorBuilder: (c, o, s) => Image.asset(
                                          Images.placeholderBanner,
                                          height: 85,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: banner.bannerList!.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () => _controller.animateToPage(entry.key),
                                child: Container(
                                  width: 12.0,
                                  height: 12.0,
                                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(_current == entry.key ? 0.9 : 0.4)),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ],
                  )
                : Center(child: Text(getTranslated('no_banner_available', context)!))
            : const BannerShimmer();
      },
    );
  }
}

// class BannerView extends StatelessWidget {
//   const BannerView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<BannerProvider>(
//       builder: (context, banner, child) {
//         final double width = MediaQuery.of(context).size.width;
//         return banner.bannerList != null
//             ? banner.bannerList!.isNotEmpty
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(10, 20, 0, 10),
//                         child: TitleWidget(title: getTranslated('banner', context)),
//                       ),
//                       CarouselSlider.builder(
//                         itemCount: banner.bannerList?.length,
//                         options: CarouselOptions(
//                           viewportFraction: 1.0,
//                           aspectRatio: 2.5,
//                           enableInfiniteScroll: false,
//                         ),
//                         itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
//                           return Consumer<CartProvider>(builder: (context, cartProvider, child) {
//                             return GestureDetector(
//                               onTap: () {
//                                 if (banner.bannerList![itemIndex].productId != null) {
//                                   Product? product;
//                                   for (Product prod in banner.productList) {
//                                     if (prod.id == banner.bannerList![itemIndex].productId) {
//                                       product = prod;
//                                       break;
//                                     }
//                                   }
//                                   if (product != null) {
//                                     ResponsiveHelper.isMobile()
//                                         ? showModalBottomSheet(
//                                             context: context,
//                                             isScrollControlled: true,
//                                             backgroundColor: Colors.transparent,
//                                             builder: (con) => CartBottomSheet(
//                                               product: product,
//                                               callback: (CartModel cartModel) {
//                                                 showCustomSnackBar(getTranslated('added_to_cart', context),
//                                                     isError: false);
//                                               },
//                                             ),
//                                           )
//                                         : showDialog(
//                                             context: context,
//                                             builder: (con) => Dialog(
//                                                   backgroundColor: Colors.transparent,
//                                                   child: CartBottomSheet(
//                                                     product: product,
//                                                     callback: (CartModel cartModel) {
//                                                       showCustomSnackBar(
//                                                           getTranslated('added_to_cart', context),
//                                                           isError: false);
//                                                     },
//                                                   ),
//                                                 ));
//                                   }
//                                 } else if (banner.bannerList![itemIndex].categoryId != null) {
//                                   CategoryModel? category;
//                                   for (CategoryModel categoryModel
//                                       in Provider.of<CategoryProvider>(context, listen: false)
//                                           .categoryList!) {
//                                     if (categoryModel.id == banner.bannerList![itemIndex].categoryId) {
//                                       category = categoryModel;
//                                       break;
//                                     }
//                                   }
//                                   if (category != null) {
//                                     Navigator.pushNamed(context, Routes.getCategoryRoute(category));
//                                   }
//                                 }
//                               },
//                               child: Container(
//                                 padding: const EdgeInsetsDirectional.only(start: 12, end: 12),
//                                 decoration: BoxDecoration(
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors
//                                           .grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 300]!,
//                                       blurRadius: Provider.of<ThemeProvider>(context).darkTheme ? 2 : 5,
//                                       spreadRadius: Provider.of<ThemeProvider>(context).darkTheme ? 0 : 1,
//                                     )
//                                   ],
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: FadeInImage.assetNetwork(
//                                     placeholder: Images.placeholderBanner,
//                                     fit: BoxFit.fill,
//                                     image:
//                                         '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${banner.bannerList![itemIndex].image}',
//                                     imageErrorBuilder: (c, o, s) => Image.asset(
//                                       Images.placeholderBanner,
//                                       height: 85,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           });
//                         },
//                       ),
//                     ],
//                   )
//                 : Center(child: Text(getTranslated('no_banner_available', context)!))
//             : const BannerShimmer();
//       },
//     );
//   }
// }

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
        itemCount: 5,
        options: CarouselOptions(
          enableInfiniteScroll: false,
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
        ),
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          return Shimmer(
            duration: const Duration(seconds: 2),
            enabled: Provider.of<BannerProvider>(context).bannerList == null,
            child: Container(
              width: 250,
              height: 85,
              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 300]!,
                    blurRadius: Provider.of<ThemeProvider>(context).darkTheme ? 2 : 5,
                    spreadRadius: Provider.of<ThemeProvider>(context).darkTheme ? 0 : 1,
                  )
                ],
                color: Theme.of(context).shadowColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        });
  }
}
