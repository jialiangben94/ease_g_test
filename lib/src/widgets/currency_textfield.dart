import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

import '../util/function.dart';

class CurrencyTextField extends StatefulWidget {
  final dynamic obj;
  final String? currency;
  final Function(dynamic obj)? onChanged;

  const CurrencyTextField(
      {Key? key, this.obj, this.currency = "RM ", this.onChanged})
      : super(key: key);

  @override
  CurrencyTextFieldState createState() => CurrencyTextFieldState();
}

class CurrencyTextFieldState extends State<CurrencyTextField> {
  dynamic obj;
  String? label;
  dynamic labelColor;
  bool? isRequired;
  int? maxLength;
  int? fieldWidth;
  int? textWidth;
  int? emptyWidth;
  double? columnHeight;
  bool? column;
  dynamic size;
  String? error;

  final ValueNotifier<String?> _textHasErrorNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    obj = widget.obj ?? {};
    label = obj["label"];
    labelColor = obj["labelColor"];
    if (labelColor is String) {
      labelColor = Color(int.parse(labelColor, radix: 16));
    }
    fieldWidth = obj["fieldWidth"] ?? 70;
    textWidth = obj["textWidth"] ?? 22;
    emptyWidth = obj["emptyWidth"] ?? 10;
    columnHeight = gFontSize;
    columnHeight = obj["columnHeight"] != null && obj["columnHeight"] is! int
        ? double.tryParse(obj["columnHeight"])
        : columnHeight;

    column = obj["column"] ?? false;
    if (column != null && column!) {
      fieldWidth = 70;
      textWidth = 85;
      emptyWidth = 30;
    }
    size = obj["size"] ?? {};
    if (size != null && !size.isEmpty) {
      fieldWidth = size["fieldWidth"] ?? fieldWidth;
      textWidth = size["textWidth"] ?? textWidth;
      emptyWidth = size["emptyWidth"] ?? emptyWidth;
      columnHeight = size["columnHeight"] ?? columnHeight;
    }
    maxLength = obj["maxLength"] ?? maxLength;
    // onChanged = obj["onChanged"] ?? widget.onChanged;
  }

  @override
  Widget build(BuildContext context) {
    calculateFontSize(context);
    String? value = obj["value"];
    isRequired = obj["required"] ?? false;

    Widget buildTextField() {
      return Expanded(
          flex: fieldWidth!,
          child: FocusScope(
              child: Focus(
                  onFocusChange: (focus) {
                    if (value != null) value = value!.trim();
                    if (isRequired == false) {
                      error = null;
                    } else {
                      if (value == null || value!.isEmpty) {
                        error = "$label ${getLocale("cannot be empty")}!";
                      } else {
                        error = null;
                      }
                    }

                    if (error == null) {
                      obj.remove("error");
                      widget.onChanged!(value);
                    } else {
                      obj["error"] = error;
                    }

                    if (_textHasErrorNotifier.value != error) {
                      _textHasErrorNotifier.value = error;
                    }
                  },
                  child: TextFormField(
                      cursorColor: Colors.grey,
                      style: bFontW5(),
                      decoration: textFieldInputDecoration().copyWith(
                          prefixText: 'RM ',
                          prefixStyle: bFontW5(),
                          counterText: "",
                          errorText: error),
                      controller: TextEditingController.fromValue(
                          TextEditingValue(
                              text: value ?? "",
                              selection: TextSelection.collapsed(
                                  offset: value!.length))),
                      inputFormatters: [
                        CurrencyTextInputFormatter(locale: 'ms', symbol: '')
                      ],
                      keyboardType: TextInputType.number,
                      maxLength: maxLength,
                      onFieldSubmitted: (data) {
                        value = data;
                        widget.onChanged!(data);
                      },
                      onChanged: (val) {
                        value = val;
                        widget.onChanged!(value);
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                        widget.onChanged!(value);
                      }))));
    }

    Widget textField = ValueListenableBuilder(
        valueListenable: _textHasErrorNotifier,
        builder: (BuildContext context, String? hasError, Widget? child) {
          return buildTextField();
        });

    List<Widget> inWidList = [];
    Widget labelWidget;
    if (label == "") {
      labelWidget = Container();
    } else {
      if (isRequired == true) {
        labelWidget = RichText(
            text: TextSpan(
                text: label,
                style: bFontWN().copyWith(color: labelColor),
                children: <TextSpan>[
              TextSpan(
                  text: "*", style: bFontWN().copyWith(color: scarletRedColor))
            ]));
      } else {
        labelWidget =
            Text(label!, style: bFontWN().copyWith(color: labelColor));
      }
    }

    if (column != null && column!) {
      inWidList.add(labelWidget);
      inWidList.add(SizedBox(height: columnHeight));
      inWidList.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textField,
            Expanded(flex: emptyWidth!, child: const SizedBox())
          ]));
    } else {
      inWidList
          .add(Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(flex: textWidth!, child: labelWidget),
        textField,
        Expanded(flex: emptyWidth!, child: const SizedBox())
      ]));
    }

    return Container(
        padding: EdgeInsets.symmetric(vertical: gFontSize * 0.5),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: inWidList));
  }
}
