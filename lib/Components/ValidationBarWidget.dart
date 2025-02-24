import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Utilities/SizeConfig.dart';

/// ValidationBarWidget that represent style of each one of them and shows under the TextField
class ValidationBarComponent extends StatelessWidget {
  final Color color;

  ValidationBarComponent({required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: new Container(
        /// We Can set, width: double.maxFinite,
        margin: EdgeInsets.symmetric(horizontal: 5),
        height: 3,
        decoration: new BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(1.5))),
      ),
    );
  }
}
