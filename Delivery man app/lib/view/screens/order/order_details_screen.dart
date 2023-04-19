import 'dart:math';

import 'package:emarket_delivery_boy/data/model/body/TrackBody.dart';
import 'package:emarket_delivery_boy/data/model/response/order_model.dart';
import 'package:emarket_delivery_boy/helper/date_converter.dart';
import 'package:emarket_delivery_boy/helper/price_converter.dart';
import 'package:emarket_delivery_boy/localization/language_constrants.dart';
import 'package:emarket_delivery_boy/provider/auth_provider.dart';
import 'package:emarket_delivery_boy/provider/localization_provider.dart';
import 'package:emarket_delivery_boy/provider/location_provider.dart';
import 'package:emarket_delivery_boy/provider/order_provider.dart';
import 'package:emarket_delivery_boy/provider/splash_provider.dart';
import 'package:emarket_delivery_boy/provider/theme_provider.dart';
import 'package:emarket_delivery_boy/provider/tracker_provider.dart';
import 'package:emarket_delivery_boy/utill/dimensions.dart';
import 'package:emarket_delivery_boy/utill/images.dart';
import 'package:emarket_delivery_boy/utill/styles.dart';
import 'package:emarket_delivery_boy/view/base/custom_button.dart';
import 'package:emarket_delivery_boy/view/base/custom_snackbar.dart';
import 'package:emarket_delivery_boy/view/screens/chat/chat_screen.dart';
import 'package:emarket_delivery_boy/view/screens/home/widget/order_widget.dart';
import 'package:emarket_delivery_boy/view/screens/order/order_place_screen.dart';
import 'package:emarket_delivery_boy/view/screens/order/widget/custom_divider.dart';
import 'package:emarket_delivery_boy/view/screens/order/widget/delivery_dialog.dart';
import 'package:emarket_delivery_boy/view/screens/order/widget/slider_button.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel orderModel;
  final int index;
  OrderDetailsScreen({this.orderModel, @required this.index});

  @override
  Widget build(BuildContext context) {
    Provider.of<OrderProvider>(context, listen: false).getOrderDetails(orderModel.id.toString(), context);
    double deliveryCharge = 0;
    if(orderModel.orderType == 'delivery') {
      deliveryCharge = orderModel.deliveryCharge;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).textTheme.bodyText1.color,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          getTranslated('order_details', context),
          style: Theme.of(context).textTheme.headline3.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).textTheme.bodyText1.color),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, order, child) {
          double _itemsPrice = 0;
          double _discount = 0;
          double _tax = 0;
          if (order.orderDetails != null) {
            order.orderDetails.forEach((orderDetails) {
              _itemsPrice = _itemsPrice + (orderDetails.price * orderDetails.quantity);
              _discount = _discount + (orderDetails.discountOnProduct * orderDetails.quantity);
              _tax = _tax + (orderDetails.taxAmount * orderDetails.quantity);
            });
          }
          double _subTotal = _itemsPrice + _tax;
          double totalPrice = _subTotal - _discount + deliveryCharge - orderModel.couponDiscountAmount;

          return order.orderDetails != null
              ? Column(
                children: [
                  Expanded(
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      children: [
                        Row(children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('${getTranslated('order_id', context)}', style: rubikRegular.copyWith(color: Theme.of(context).highlightColor)),
                                Text(' # ${orderModel.id}', style: rubikMedium.copyWith(color: Theme.of(context).highlightColor)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.watch_later, size: 17),
                                SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                Text(DateConverter.isoStringToLocalDateOnly(orderModel.createdAt),
                                    style: rubikRegular.copyWith(color: Theme.of(context).highlightColor)),
                              ],
                            ),
                          ),
                        ]),
                        SizedBox(height: 20),

                        Container(
                          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                              color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 300],
                              blurRadius: 5, spreadRadius: 1,
                            )],
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(getTranslated('customer', context), style: rubikRegular.copyWith(
                              fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                              color: Theme.of(context).highlightColor,
                            )),
                            ListTile(
                              leading: ClipOval(
                                child: FadeInImage.assetNetwork(
                                  placeholder: Images.placeholder,
                                  image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.customerImageUrl}/${
                                     orderModel.customer != null ? orderModel.customer.image ?? '' : ''}',
                                  height: 40, width: 40, fit: BoxFit.cover,
                                  imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 40, width: 40, fit: BoxFit.cover),
                                ),
                              ),
                              title: Text(
                                orderModel.customer != null
                                    ? '${orderModel.customer.fName ?? ''} ${orderModel.customer.lName ?? ''}' : getTranslated('user_not_available', context),
                                style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor),
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  if(orderModel.customer != null) {
                                    launchUrlString('tel:${orderModel.customer.phone}');
                                  }else{
                                    showCustomSnackBar(getTranslated('user_not_available', context), context);
                                  }

                                },
                                child: Container(
                                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).shadowColor),
                                  child: Icon(Icons.call_outlined, color: Colors.black),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Text('${getTranslated('item', context)}:', style: rubikRegular.copyWith(color: Theme.of(context).highlightColor)),
                              SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              Text(order.orderDetails.length.toString(), style: rubikMedium.copyWith(color: Theme.of(context).primaryColor)),
                            ]),
                            orderModel.orderStatus == 'processing' || orderModel.orderStatus == 'out_for_delivery'
                                ? Row(children: [
                                    Text('${getTranslated('payment_status', context)}:',
                                        style: rubikRegular.copyWith(color: Theme.of(context).highlightColor)),
                                    SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                    Text(getTranslated('${orderModel.paymentStatus}', context),
                                        style: rubikMedium.copyWith(color: Theme.of(context).primaryColor)),
                                  ])
                                : SizedBox.shrink(),
                          ],
                        ),
                        Divider(height: 20),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: order.orderDetails.length,
                          itemBuilder: (context, index) {
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: Images.placeholder,
                                    image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${order.orderDetails[index].productDetails.image[0]}',
                                    height: 70, width: 80, fit: BoxFit.cover, imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 70, width: 80, fit: BoxFit.cover),
                                  ),
                                ),
                                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            order.orderDetails[index].productDetails.name,
                                            style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).highlightColor),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(getTranslated('amount', context), style: rubikRegular.copyWith(color: Theme.of(context).highlightColor)),
                                      ],
                                    ),
                                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Row(
                                        children: [
                                          Text('${getTranslated('quantity', context)}:',
                                              style: rubikRegular.copyWith(color: Theme.of(context).highlightColor)),
                                          Text(' ${order.orderDetails[index].quantity}',
                                              style: rubikMedium.copyWith(color: Theme.of(context).primaryColor)),
                                        ],
                                      ),
                                      Text(
                                        PriceConverter.convertPrice(context, order.orderDetails[index].price),
                                        style: rubikMedium.copyWith(color: Theme.of(context).primaryColor),
                                      ),
                                    ]),
                                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                                    order.orderDetails[index].variation.length > 0 ?
                                    Row(children: [
                                      order.orderDetails[index].variation.first.type != null ?
                                      Container(height: 10, width: 10, decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).textTheme.bodyText1.color,
                                      )) : SizedBox.shrink(),
                                      SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                                      Text(order.orderDetails[index].variation.first.type ?? '',
                                        style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                      ),
                                    ]):SizedBox() ,
                                  ]),
                                ),
                              ]),
                              Divider(height: 20),
                            ]);
                          },
                        ),

                        (orderModel.orderNote != null && orderModel.orderNote.isNotEmpty) ? Container(
                          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                          margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_LARGE),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1, color: Theme.of(context).hintColor),
                          ),
                          child: Text(orderModel.orderNote, style: rubikRegular.copyWith(color: Theme.of(context).hintColor)),
                        ) : SizedBox(),

                        // Total
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(getTranslated('items_price', context), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                          Text(PriceConverter.convertPrice(context, _itemsPrice), style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                        ]),
                        SizedBox(height: 10),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(getTranslated('tax', context),
                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor)),
                          Text('(+) ${PriceConverter.convertPrice(context, _tax)}',
                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor)),
                        ]),
                        SizedBox(height: 10),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                          child: CustomDivider(),
                        ),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(getTranslated('subtotal', context),
                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor)),
                          Text(PriceConverter.convertPrice(context, _subTotal),
                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor)),
                        ]),
                        SizedBox(height: 10),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(getTranslated('discount', context),
                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor)),
                          Text('(-) ${PriceConverter.convertPrice(context, _discount)}',
                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor)),
                        ]),
                        SizedBox(height: 10),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(getTranslated('coupon_discount', context),
                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor)),
                          Text(
                            '(-) ${PriceConverter.convertPrice(context, orderModel.couponDiscountAmount)}',
                            style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor),
                          ),
                        ]),
                        SizedBox(height: 10),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(getTranslated('delivery_fee', context),
                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor)),
                          Text('(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
                              style: rubikRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).highlightColor)),
                        ]),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                          child: CustomDivider(),
                        ),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(getTranslated('total_amount', context),
                              style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor)),
                          Text(
                            PriceConverter.convertPrice(context, totalPrice),
                            style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor),
                          ),
                        ]),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                  orderModel.orderStatus == 'processing' || orderModel.orderStatus == 'out_for_delivery'
                      ? Consumer<LocationProvider>(
                    builder: (context, locationProvider, child) => Padding(
                      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomButton(
                          btnTxt: getTranslated('direction', context),
                          onTap: () {
                            MapUtils.openMap(
                                double.parse(orderModel.deliveryAddress.latitude) ?? 23.8103,
                                double.parse(orderModel.deliveryAddress.longitude) ?? 90.4125,
                                locationProvider.currentLocation.latitude ?? 23.81,
                                locationProvider.currentLocation.longitude ?? 90.4125);
                          }),
                    ),
                  )
                      : SizedBox.shrink(),
                  orderModel.orderStatus != 'delivered' ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomButton(btnTxt: getTranslated('chat_with_customer', context), onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(orderModel: orderModel)));
                      }),
                    ),
                  ) : SizedBox(),

                  orderModel.orderStatus == 'processing' ? Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.05)),
                      color: Theme.of(context).backgroundColor,
                    ),
                    child: Transform.rotate(
                      angle: Provider.of<LocalizationProvider>(context).isLtr ? pi * 2 : pi, // in radians
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: SliderButton(
                          action: () {
                            String token = Provider.of<AuthProvider>(context, listen: false).getUserToken();
                            Placemark address = Provider.of<LocationProvider>(context, listen: false).address;
                            TrackBody trackBody = TrackBody(
                                token: token,
                                latitude: Provider.of<LocationProvider>(context, listen: false).currentLocation.latitude ?? 23.8103,
                                longitude: Provider.of<LocationProvider>(context, listen: false).currentLocation.longitude ?? 90.4125,
                                location: '${address.name ?? ''}, ${address.subAdministrativeArea ?? ''}, ${address.isoCountryCode ?? ''}' ?? 'demo',
                                orderId: orderModel.id.toString());
                            Provider.of<TrackerProvider>(context, listen: false).updateTrackStart(true);

                            Provider.of<TrackerProvider>(context, listen: false).addTrack(trackBody: trackBody).then((value) {
                              Provider.of<OrderProvider>(context, listen: false)
                                  .updateOrderStatus(token: token, orderId: orderModel.id, status: 'out_for_delivery', index: index);
                              Provider.of<OrderProvider>(context, listen: false).getAllOrders(context);
                              Navigator.pop(context);
                            });
                          },

                          ///Put label over here
                          label: Text(
                            getTranslated('swip_to_deliver_order', context),
                            style: Theme.of(context).textTheme.headline3.copyWith(color: Theme.of(context).primaryColor),
                          ),
                          dismissThresholds: 0.5,
                          icon: Center(
                              child: Icon(
                                Icons.double_arrow_sharp,
                                color: Colors.white,
                                size: 20.0,
                                semanticLabel: 'Text to announce in accessibility modes',
                              )),

                          ///Change All the color and size from here.
                          radius: 10,
                          boxShadow: BoxShadow(blurRadius: 0.0),
                          buttonColor: Theme.of(context).primaryColor,
                          backgroundColor: Theme.of(context).backgroundColor,
                          baseColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                      : orderModel.orderStatus == 'out_for_delivery'
                      ? Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.05)),
                      color: Theme.of(context).backgroundColor,
                    ),
                    child: Transform.rotate(
                      angle: Provider.of<LocalizationProvider>(context).isLtr ? pi * 2 : pi, // in radians
                      child: Directionality(
                        textDirection: TextDirection.ltr, // set it to rtl
                        child: SliderButton(
                          action: () {
                            String token = Provider.of<AuthProvider>(context, listen: false).getUserToken();

                            if (orderModel.paymentStatus == 'paid') {
                              Provider.of<OrderProvider>(context, listen: false)
                                  .updateOrderStatus(token: token, orderId: orderModel.id, status: 'delivered', index: index);
                              Provider.of<TrackerProvider>(context, listen: false).updateTrackStart(false);
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => OrderPlaceScreen(orderID: orderModel.id.toString())));
                            } else {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                      child: DeliveryDialog(
                                        onTap: () {},
                                        index: index,
                                        totalPrice: totalPrice,
                                        orderModel: orderModel,
                                      ),
                                    );
                                  });
                            }
                          },

                          ///Put label over here
                          label: Text(
                            getTranslated('swip_to_confirm_order', context),
                            style: Theme.of(context).textTheme.headline3.copyWith(color: Theme.of(context).primaryColor),
                          ),
                          dismissThresholds: 0.5,
                          icon: Center(
                              child: Icon(
                                Icons.double_arrow_sharp,
                                color: Colors.white,
                                size: 20.0,
                                semanticLabel: 'Text to announce in accessibility modes',
                              )),

                          ///Change All the color and size from here.
                          radius: 10,
                          boxShadow: BoxShadow(blurRadius: 0.0),
                          buttonColor: Theme.of(context).primaryColor,
                          backgroundColor: Theme.of(context).backgroundColor,
                          baseColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                      : SizedBox.shrink(),

                ],
              )
              : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
        },
      ),
    );
  }
}
