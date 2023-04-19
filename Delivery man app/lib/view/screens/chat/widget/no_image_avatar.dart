import 'package:flutter/material.dart';
import 'package:emarket_delivery_boy/utill/dimensions.dart';
import 'package:emarket_delivery_boy/utill/images.dart';

class NoImageAvatar extends StatelessWidget {
  const NoImageAvatar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: Dimensions.PADDING_SIZE_DEFAULT,
      child: ClipRRect(
        child: Image.asset(Images.placeholder), borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }
}
