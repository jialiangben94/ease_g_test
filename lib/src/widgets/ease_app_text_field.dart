import 'dart:math';

import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/function.dart';

class EaseAppTextField extends StatelessWidget {
  final dynamic obj;

  final String objKey;
  final String type;
  final String label;
  final String? value;

  final dynamic labelColor;

  final bool isRequired;
  final bool enabled;
  final bool disableEdit;
  final bool column;
  final bool sentence;
  final bool isObj = false;

  final int fieldWidth;
  final int textWidth;
  final int emptyWidth;
  final int? maxLines;
  final int? maxLength;
  final double? columnHeight;

  final String placeholder;
  final String? regex;
  final String? regexError;
  final String? populateError;
  final String? error;

  final String prefix;
  final dynamic maskFormat;
  final dynamic maskFilter;

  final Function(dynamic obj) onChanged;
  final Function(dynamic obj)? callback;
  final Function(bool)? onFocusChanged;
  final ValueNotifier<String?> _textHasErrorNotifier = ValueNotifier(null);

  EaseAppTextField(
      {Key? key,
      this.obj,
      this.objKey = "",
      this.type = "text",
      this.label = "",
      this.labelColor = Colors.black,
      this.value = "",
      this.isRequired = true,
      this.enabled = true,
      this.disableEdit = false,
      this.column = false,
      this.sentence = false,
      this.fieldWidth = 70,
      this.textWidth = 22,
      this.emptyWidth = 10,
      this.columnHeight,
      this.maxLength,
      this.maxLines,
      this.placeholder = "",
      this.regex,
      this.regexError,
      this.populateError,
      this.error,
      this.prefix = "",
      this.maskFormat,
      this.maskFilter,
      this.callback,
      this.onFocusChanged,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    calculateFontSize(context);

    dynamic nobj = obj ?? {};
    String nobjKey = nobj["objKey"] ?? objKey;
    String ntype = nobj["type"] ?? type;
    String nlabel = nobj["label"] ?? label;
    String? nvalue = nobj["value"] ?? value;
    dynamic nlabelColor = nobj["labelColor"] ?? labelColor;
    if (nlabelColor is String) {
      nlabelColor = Color(int.parse(nlabelColor, radix: 16));
    }
    bool isRequiredn = nobj["required"] ?? isRequired;
    bool enabledn = nobj["enabled"] ?? enabled;
    if (!enabledn) {
      return const SizedBox();
    }
    bool ndisableEdit = nobj["disableEdit"] ?? disableEdit;
    bool nsentence = nobj["sentence"] ?? sentence;

    bool isObj = false;
    if (nobj != null && !nobj.isEmpty) isObj = true;
    if (nobj["size"] != null && nobj["size"] is! Map) nobj["size"] = null;

    int nfieldWidth = nobj["fieldWidth"] ?? fieldWidth;
    int ntextWidth = nobj["textWidth"] ?? textWidth;
    int nemptyWidth = nobj["emptyWidth"] ?? emptyWidth;
    double? ccolumnHeight = gFontSize;
    ccolumnHeight = nobj["columnHeight"] != null && nobj["columnHeight"] is! int
        ? double.tryParse(nobj["columnHeight"])
        : ccolumnHeight;

    bool columnn = nobj["column"] ?? column;
    if (columnn) {
      nfieldWidth = 70;
      ntextWidth = 85;
      nemptyWidth = 30;
    }

    dynamic size = nobj["size"] ?? {};
    if (size != null && !size.isEmpty) {
      nfieldWidth = size["fieldWidth"] ?? nfieldWidth;
      ntextWidth = size["textWidth"] ?? ntextWidth;
      nemptyWidth = size["emptyWidth"] ?? nemptyWidth;
      ccolumnHeight = size["columnHeight"] ?? ccolumnHeight;
    }

    int? mmaxLength = nobj["maxLength"] ?? maxLength;
    int? mmaxLines = nobj["maxLines"] ?? maxLines;

    String pplaceholder = nobj["placeholder"] ?? placeholder;
    String? regexn = nobj["regex"] ?? regex;
    String? regexnError = nobj["regexError"] ?? regexError;
    String? ppopulateError = nobj["populateError"] ?? populateError;
    String? eerror = nobj["error"] ?? error;
    String pprefix = nobj["prefix"] ?? prefix;

    dynamic mmaskFormat = nobj["maskFormat"] ?? maskFormat;
    dynamic maskFilter2 = nobj["maskFilter"] ?? maskFilter;
    if (mmaskFormat != null && mmaskFormat != "") {
      Map<String?, RegExp>? mf;
      if (maskFilter2 != null && maskFilter2 is Map) {
        mf = {};
        for (var key in maskFilter2.keys) {
          mf[key] = RegExp(r"" + maskFilter2[key]);
        }
      }
      mmaskFormat = MaskFormatter(mask: mmaskFormat, filter: mf);
    }

    Function(dynamic) onChangedn = nobj["onChanged"] ?? onChanged;
    Function(dynamic)? callbackn = nobj["callback"] ?? callback;

    // String? convert(val) {
    //   if (pprefix == "RM " && val != "") {
    //     double value = double.parse(val);
    //     final formatter = NumberFormat("#,##0.00", "en_US");
    //     val = formatter.format(value / 100);
    //   }
    //   return val;
    // }

    Widget buildTextField() {
      return Expanded(
          flex: nfieldWidth,
          child: FocusScope(
              child: Focus(
                  onFocusChange: onFocusChanged ??
                      (focus) {
                        if (focus || ndisableEdit) return;
                        if (regexn == null || regexn is! String) regexn = "";
                        final r = RegExp(r"" + regexn!);

                        if (isObj) nvalue = nobj["value"];

                        if (nvalue != null) nvalue = nvalue!.trim();
                        if (regexnError != null && !r.hasMatch(nvalue!)) {
                          eerror = regexnError;
                        } else if (ppopulateError != null) {
                          eerror = ppopulateError;
                        } else if (isRequiredn == false) {
                          eerror = null;
                        } else if (nvalue == null || nvalue!.isEmpty) {
                          eerror = "$nlabel ${getLocale("cannot be empty")}!";
                        } else {
                          if (!r.hasMatch(nvalue!)) {
                            eerror =
                                "${getLocale("Please enter a valid")} $nlabel";
                          } else if (nlabel == getLocale("Full Name") &&
                              nvalue!.length < 5) {
                            eerror =
                                "$nlabel ${getLocale("must contain at least 5 characters")}";
                          } else {
                            eerror = null;
                          }
                        }

                        if (_textHasErrorNotifier.value != eerror) {
                          _textHasErrorNotifier.value = eerror;
                        }

                        if (isObj) {
                          if (eerror == null) {
                            nobj.remove("error");
                          } else {
                            nobj["error"] = eerror;
                          }
                        }

                        if (callbackn is Function) callbackn!(nobjKey);
                      },
                  child: TextFormField(
                      autofillHints: ntype == "email"
                          ? [AutofillHints.email]
                          : ntype == "telnumber"
                              ? [AutofillHints.telephoneNumber]
                              : null,
                      readOnly: ndisableEdit,
                      controller: TextEditingController.fromValue(
                          TextEditingValue(
                              text: nvalue ?? "",
                              selection: TextSelection.collapsed(
                                  offset: nvalue!.length))),
                      keyboardType: ntype == "number" || ntype == "telnumber"
                          ? TextInputType.number
                          : ntype == "email"
                              ? TextInputType.emailAddress
                              : TextInputType.text,
                      inputFormatters: mmaskFormat != null
                          ? [mmaskFormat]
                          : ntype == "number" || ntype == "telnumber"
                              ? <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ]
                              : [],
                      onChanged: (val) {
                        if (ntype == "telnumber") {
                          if (val.length > 11 && val.substring(0, 2) == "60") {
                            val = val.replaceAll("60", "");
                          }
                        }
                        nvalue = val;
                        onChangedn(nvalue);
                      },
                      onFieldSubmitted: (val) {
                        nvalue = val;
                        onChangedn(nvalue);
                      },
                      maxLines: mmaxLines,
                      maxLength: mmaxLength,
                      cursorColor: Colors.grey,
                      textCapitalization: ntype == "email"
                          ? TextCapitalization.none
                          : nsentence
                              ? TextCapitalization.sentences
                              : TextCapitalization.words,
                      style: bFontW5(),
                      decoration: InputDecoration(
                          prefixText: pprefix,
                          prefixStyle: bFontW5(),
                          fillColor:
                              ndisableEdit ? lightGreyColor2 : Colors.white,
                          filled: true,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: gFontSize, horizontal: gFontSize),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: greyBorderTFColor, width: 1.0)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: greyBorderTFColor, width: 1.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(
                                  color: greyBorderTFColor, width: 1.0)),
                          errorText: eerror,
                          hintText: pplaceholder,
                          counterText: "",
                          hintStyle: TextStyle(
                              color: Colors.grey[350],
                              fontWeight: FontWeight.normal))))));
    }

    Widget textField = ValueListenableBuilder(
        valueListenable: _textHasErrorNotifier,
        builder: (BuildContext context, String? hasError, Widget? child) {
          return buildTextField();
        });

    List<Widget> inWidList = [];
    Widget labelWidget;
    if (nlabel == "") {
      labelWidget = Container();
    } else {
      if (isRequiredn == true) {
        labelWidget = RichText(
            text: TextSpan(
                text: nlabel,
                style: bFontWN().copyWith(color: nlabelColor),
                children: <TextSpan>[
              TextSpan(
                  text: "*", style: bFontWN().copyWith(color: scarletRedColor))
            ]));
      } else {
        labelWidget =
            Text(nlabel, style: bFontWN().copyWith(color: nlabelColor));
      }
    }

    if (columnn) {
      inWidList.add(labelWidget);
      inWidList.add(SizedBox(height: ccolumnHeight));
      inWidList.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textField,
            Expanded(flex: nemptyWidth, child: const SizedBox())
          ]));
    } else {
      inWidList
          .add(Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(flex: ntextWidth, child: labelWidget),
        textField,
        Expanded(flex: nemptyWidth, child: const SizedBox())
      ]));
    }

    return Container(
        padding: EdgeInsets.symmetric(vertical: gFontSize * 0.5),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: inWidList));
  }
}

class MaskFormatter implements TextInputFormatter {
  String? _mask = "";
  List<String?> _maskChars = [];
  Map<String?, RegExp> _maskFilter = {};

  int _maskLength = 0;
  final TextMatcher _resultTextArray = TextMatcher();
  String _resultTextMasked = "";

  TextEditingValue? _lastResValue;
  TextEditingValue? _lastNewValue;

  /// Create the [mask] formatter for TextField
  ///
  /// The keys of the [filter] assign which character in the mask should be replaced and the values validate the entered character
  /// By default `#` match to the number and `A` to the letter
  MaskFormatter(
      {String? mask, Map<String?, RegExp>? filter, String? initialText}) {
    updateMask(
        mask: mask,
        filter: filter ?? {"#": RegExp(r'[0-9]'), "A": RegExp(r'[^0-9]')});
    if (initialText != null) {
      formatEditUpdate(
          const TextEditingValue(), TextEditingValue(text: initialText));
    }
  }

  /// Change the mask
  TextEditingValue updateMask({String? mask, Map<String?, RegExp>? filter}) {
    _mask = mask;
    if (filter != null) {
      _updateFilter(filter);
    }
    _calcMaskLength();
    final String unmaskedText = getUnmaskedText();
    clear();
    return formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(
            text: unmaskedText,
            selection: TextSelection.collapsed(offset: unmaskedText.length)));
  }

  /// Get current mask
  String? getMask() {
    return _mask;
  }

  /// Get masked text, e.g. "+0 (123) 456-78-90"
  String getMaskedText() {
    return _resultTextMasked;
  }

  /// Get unmasked text, e.g. "01234567890"
  String getUnmaskedText() {
    return _resultTextArray.toString();
  }

  /// Check if target mask is filled
  bool isFill() {
    return _resultTextArray.length == _maskLength;
  }

  /// Clear masked text of the formatter
  /// Note: you need to call this method if you clear the text of the TextField because it doesn't call the formatter when it has empty text
  void clear() {
    _resultTextMasked = "";
    _resultTextArray.clear();
    _lastResValue = null;
    _lastNewValue = null;
  }

  /// Mask some text
  String maskText(String text) {
    return MaskFormatter(mask: _mask, filter: _maskFilter, initialText: text)
        .getMaskedText();
  }

  /// Unmask some text
  String unmaskText(String text) {
    return MaskFormatter(mask: _mask, filter: _maskFilter, initialText: text)
        .getUnmaskedText();
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (_lastResValue == oldValue && newValue == _lastNewValue) {
      return oldValue;
    }
    _lastNewValue = newValue;
    return _lastResValue = _format(oldValue, newValue);
  }

  TextEditingValue _format(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final mask = _mask;

    if (mask == null || mask.isEmpty == true) {
      _resultTextMasked = newValue.text;
      _resultTextArray.set(newValue.text);
      return newValue;
    }

    final String beforeText = oldValue.text;
    final String afterText = newValue.text;

    final TextSelection beforeSelection = oldValue.selection;
    final int beforeSelectionStart =
        beforeSelection.isValid ? beforeSelection.start : 0;
    final int beforeSelectionLength = beforeSelection.isValid
        ? beforeSelection.end - beforeSelection.start
        : 0;

    final int lengthDifference =
        afterText.length - (beforeText.length - beforeSelectionLength);
    final int lengthRemoved = lengthDifference < 0 ? lengthDifference.abs() : 0;
    final int lengthAdded = lengthDifference > 0 ? lengthDifference : 0;

    final int afterChangeStart = max(0, beforeSelectionStart - lengthRemoved);
    final int afterChangeEnd = max(0, afterChangeStart + lengthAdded);

    final int beforeReplaceStart = max(0, beforeSelectionStart - lengthRemoved);
    final int beforeReplaceLength = beforeSelectionLength + lengthRemoved;

    final int beforeResultTextLength = _resultTextArray.length;

    int currentResultTextLength = _resultTextArray.length;
    int currentResultSelectionStart = 0;
    int currentResultSelectionLength = 0;

    for (var i = 0;
        i < min(beforeReplaceStart + beforeReplaceLength, mask.length);
        i++) {
      if (_maskChars.contains(mask[i]) && currentResultTextLength > 0) {
        currentResultTextLength -= 1;
        if (i < beforeReplaceStart) {
          currentResultSelectionStart += 1;
        }
        if (i >= beforeReplaceStart) {
          currentResultSelectionLength += 1;
        }
      }
    }

    final String replacementText =
        afterText.substring(afterChangeStart, afterChangeEnd);
    int targetCursorPosition = currentResultSelectionStart;
    if (replacementText.isEmpty) {
      _resultTextArray.removeRange(currentResultSelectionStart,
          currentResultSelectionStart + currentResultSelectionLength);
    } else {
      if (currentResultSelectionLength > 0) {
        _resultTextArray.removeRange(currentResultSelectionStart,
            currentResultSelectionStart + currentResultSelectionLength);
      }
      _resultTextArray.insert(currentResultSelectionStart, replacementText);
      targetCursorPosition += replacementText.length;
    }

    if (beforeResultTextLength == 0 && _resultTextArray.length > 1) {
      for (var i = 0; i < mask.length; i++) {
        if (_maskChars.contains(mask[i]) || _resultTextArray.isEmpty) {
          break;
        } else if (mask[i] == _resultTextArray[0]) {
          _resultTextArray.removeAt(0);
        }
      }
    }

    int curTextPos = 0;
    int maskPos = 0;
    _resultTextMasked = "";
    int cursorPos = -1;
    int nonMaskedCount = 0;

    while (maskPos < mask.length) {
      final String curMaskChar = mask[maskPos];
      final bool isMaskChar = _maskChars.contains(curMaskChar);

      bool curTextInRange = curTextPos < _resultTextArray.length;

      String? curTextChar;
      if (isMaskChar && curTextInRange) {
        while (curTextChar == null && curTextInRange) {
          final String potentialTextChar = _resultTextArray[curTextPos];
          if (_maskFilter[curMaskChar]?.hasMatch(potentialTextChar) == true) {
            curTextChar = potentialTextChar;
          } else {
            _resultTextArray.removeAt(curTextPos);
            curTextInRange = curTextPos < _resultTextArray.length;
            if (curTextPos <= targetCursorPosition) {
              targetCursorPosition -= 1;
            }
          }
        }
      }

      if (isMaskChar && curTextInRange && curTextChar != null) {
        _resultTextMasked += curTextChar;
        if (curTextPos == targetCursorPosition && cursorPos == -1) {
          cursorPos = maskPos - nonMaskedCount;
        }
        nonMaskedCount = 0;
        curTextPos += 1;
      } else {
        if (curTextPos == targetCursorPosition &&
            cursorPos == -1 &&
            !curTextInRange) {
          cursorPos = maskPos;
        }

        if (!curTextInRange) {
          break;
        } else {
          _resultTextMasked += mask[maskPos];
        }

        nonMaskedCount++;
      }

      maskPos += 1;
    }

    if (nonMaskedCount > 0) {
      _resultTextMasked = _resultTextMasked.substring(
          0, _resultTextMasked.length - nonMaskedCount);
      cursorPos -= nonMaskedCount;
    }

    if (_resultTextArray.length > _maskLength) {
      _resultTextArray.removeRange(_maskLength, _resultTextArray.length);
    }

    final int finalCursorPosition =
        cursorPos < 0 ? _resultTextMasked.length : cursorPos;

    return TextEditingValue(
        text: _resultTextMasked,
        selection: TextSelection(
            baseOffset: finalCursorPosition,
            extentOffset: finalCursorPosition,
            affinity: newValue.selection.affinity,
            isDirectional: newValue.selection.isDirectional));
  }

  void _calcMaskLength() {
    _maskLength = 0;
    final mask = _mask;
    if (mask != null) {
      for (int i = 0; i < mask.length; i++) {
        if (_maskChars.contains(mask[i])) {
          _maskLength++;
        }
      }
    }
  }

  void _updateFilter(Map<String?, RegExp> filter) {
    _maskFilter = filter;
    _maskChars = _maskFilter.keys.toList(growable: false);
  }
}

class TextMatcher {
  final List<String> _symbolArray = <String>[];

  int get length => _symbolArray.fold(0, (prev, match) => prev + match.length);

  void removeRange(int start, int end) => _symbolArray.removeRange(start, end);

  void insert(int start, String substring) {
    for (var i = 0; i < substring.length; i++) {
      _symbolArray.insert(start + i, substring[i]);
    }
  }

  bool get isEmpty => _symbolArray.isEmpty;

  void removeAt(int index) => _symbolArray.removeAt(index);

  String operator [](int index) => _symbolArray[index];

  void clear() => _symbolArray.clear();

  @override
  String toString() => _symbolArray.join();

  void set(String text) {
    _symbolArray.clear();
    for (int i = 0; i < text.length; i++) {
      _symbolArray.add(text[i]);
    }
  }
}
