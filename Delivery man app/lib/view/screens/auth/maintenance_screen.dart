
import 'package:flutter/material.dart';
import 'package:emarket_delivery_boy/localization/language_constrants.dart';
import 'package:emarket_delivery_boy/utill/dimensions.dart';
import 'package:emarket_delivery_boy/utill/images.dart';


class MaintenanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _paddingSize = MediaQuery.of(context).size.height * 0.025;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(_paddingSize),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

            Image.asset(Images.maintenance, width: 200, height: 200),

            Text(getTranslated('maintenance_mode', context),style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700),),
            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

            Text(
              getTranslated('maintenance_text', context),
              textAlign: TextAlign.center,

            ),

          ]),
        ),
      ),
    );
  }
}
