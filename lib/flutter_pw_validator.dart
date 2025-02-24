library flutter_pw_validator;

import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Utilities/ConditionsHelper.dart';
import 'package:flutter_pw_validator/Utilities/Validator.dart';

import 'Components/ValidationBarWidget.dart';
import 'Components/ValidationTextWidget.dart';
import 'Resource/MyColors.dart';
import 'Resource/Strings.dart';
import 'Utilities/SizeConfig.dart';

class FlutterPwValidator extends StatefulWidget {
  final int minLength,
      normalCharCount,
      uppercaseCharCount,
      lowercaseCharCount,
      numericCharCount,
      specialCharCount;
  final Color defaultColor, successColor, failureColor;
  final double width, height;
  final Function onSuccess;
  final Function? onFail;
  final TextEditingController controller;
  final FlutterPwValidatorStrings? strings;
  final Key? key;

  FlutterPwValidator(
      {required this.width,
      required this.height,
      required this.minLength,
      required this.onSuccess,
      required this.controller,
      this.uppercaseCharCount = 0,
      this.lowercaseCharCount = 0,
      this.numericCharCount = 0,
      this.specialCharCount = 0,
      this.normalCharCount = 0,
      this.defaultColor = MyColors.gray,
      this.successColor = MyColors.green,
      this.failureColor = MyColors.red,
      this.strings,
      this.onFail,
      this.key}) {
    //Initial entered size for global use
    SizeConfig.width = width;
    SizeConfig.height = height;
  }

  @override
  State<StatefulWidget> createState() => new FlutterPwValidatorState();

  FlutterPwValidatorStrings get translatedStrings =>
      this.strings ?? FlutterPwValidatorStrings();
}

@protected
class FlutterPwValidatorState extends State<FlutterPwValidator> {
  /// Estimate that this the first run or not
  late bool _isFirstRun;

  /// Variables that hold current condition states
  dynamic _hasMinLength,
      _hasMinNormalChar,
      _hasMinUppercaseChar,
      _hasMinLowercaseChar,
      _hasMinNumericChar,
      _hasMinSpecialChar;

  //Initial instances of ConditionHelper and Validator class
  late final ConditionsHelper _conditionsHelper;
  Validator _validator = new Validator();

  /// Get called each time that user entered a character in EditText
  void validate() {
    /// For each condition we called validators and get their new state
    _hasMinLength = _conditionsHelper.checkCondition(
        widget.minLength,
        _validator.hasMinLength,
        widget.controller,
        widget.translatedStrings.atLeast,
        _hasMinLength);

    _hasMinNormalChar = _conditionsHelper.checkCondition(
        widget.normalCharCount,
        _validator.hasMinNormalChar,
        widget.controller,
        widget.translatedStrings.normalLetters,
        _hasMinNormalChar);

    _hasMinUppercaseChar = _conditionsHelper.checkCondition(
        widget.uppercaseCharCount,
        _validator.hasMinUppercase,
        widget.controller,
        widget.translatedStrings.uppercaseLetters,
        _hasMinUppercaseChar);

    _hasMinLowercaseChar = _conditionsHelper.checkCondition(
        widget.lowercaseCharCount,
        _validator.hasMinLowercase,
        widget.controller,
        widget.translatedStrings.lowercaseLetters,
        _hasMinLowercaseChar);

    _hasMinNumericChar = _conditionsHelper.checkCondition(
        widget.numericCharCount,
        _validator.hasMinNumericChar,
        widget.controller,
        widget.translatedStrings.numericCharacters,
        _hasMinNumericChar);

    _hasMinSpecialChar = _conditionsHelper.checkCondition(
        widget.specialCharCount,
        _validator.hasMinSpecialChar,
        widget.controller,
        widget.translatedStrings.specialCharacters,
        _hasMinSpecialChar);

    /// Checks if all condition are true then call the onSuccess and if not, calls onFail method
    int conditionsCount = _conditionsHelper.getter()!.length;
    int trueCondition = 0;
    for (bool value in _conditionsHelper.getter()!.values) {
      if (value == true) trueCondition += 1;
    }
    if (conditionsCount == trueCondition)
      widget.onSuccess();
    else if (widget.onFail != null) widget.onFail!();

    //To prevent from calling the setState() after dispose()
    if (!mounted) return;

    //Rebuild the UI
    setState(() => null);
    trueCondition = 0;
  }

  @override
  void initState() {
    super.initState();
    _isFirstRun = true;

    _conditionsHelper = ConditionsHelper(widget.translatedStrings);

    /// Sets user entered value for each condition
    _conditionsHelper.setSelectedCondition(
        widget.minLength,
        widget.normalCharCount,
        widget.uppercaseCharCount,
        widget.lowercaseCharCount,
        widget.numericCharCount,
        widget.specialCharCount);

    /// Adds a listener callback on TextField to run after input get changed
    widget.controller.addListener(() {
      _isFirstRun = false;
      validate();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: SizeConfig.width,
      height: widget.height,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          new Flexible(
            flex: 1,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Iterate through the conditions map values to check if there is any true values then create green ValidationBarComponent.
                for (bool value in _conditionsHelper.getter()!.values)
                  if (value == true)
                    new ValidationBarComponent(color: widget.successColor),

                // Iterate through the conditions map values to check if there is any false values then create red ValidationBarComponent.
                for (bool value in _conditionsHelper.getter()!.values)
                  if (value == false)
                    new ValidationBarComponent(color: widget.defaultColor)
              ],
            ),
          ),
          new Flexible(
            flex: 7,
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                //Iterate through the condition map entries and generate new ValidationTextWidget for each item in Green or Red Color
                children: _conditionsHelper.getter()!.entries.map((entry) {
                  int? value;
                  if (entry.key == widget.translatedStrings.atLeast)
                    value = widget.minLength;
                  if (entry.key == widget.translatedStrings.normalLetters)
                    value = widget.normalCharCount;
                  if (entry.key == widget.translatedStrings.uppercaseLetters)
                    value = widget.uppercaseCharCount;
                  if (entry.key == widget.translatedStrings.lowercaseLetters)
                    value = widget.lowercaseCharCount;
                  if (entry.key == widget.translatedStrings.numericCharacters)
                    value = widget.numericCharCount;
                  if (entry.key == widget.translatedStrings.specialCharacters)
                    value = widget.specialCharCount;
                  return new ValidationTextWidget(
                    color: _isFirstRun
                        ? widget.defaultColor
                        : entry.value
                            ? widget.successColor
                            : widget.failureColor,
                    text: entry.key,
                    value: value,
                  );
                }).toList()),
          )
        ],
      ),
    );
  }
}
