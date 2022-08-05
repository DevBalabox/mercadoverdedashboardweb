import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/utils/validation.dart';

class SimpleTextField extends StatefulWidget {
  const SimpleTextField({
    this.fieldKey,
    @required this.inputType,
    this.maxLength,
    this.maxLines,
    @required this.enabled,
    this.initValue,
    this.hintText,
    this.labelText,
    this.helperText,
    @required this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.icon,
    this.textKeyboardType,
    @required this.textCapitalization,
    this.context,
    this.inpAction,
    this.mainColor,
    this.onChanged,
  });

  final BuildContext context;
  final Key fieldKey;
  final int maxLength;
  final int maxLines;
  final bool enabled;
  final String initValue;
  final String inputType;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> onChanged;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;
  final IconData icon;
  final TextInputType textKeyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction inpAction;
  final Color mainColor;

  @override
  _SimpleTextFieldState createState() => _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<SimpleTextField> {
  bool _obscureText = true;
  var validator = genericValidator;

  @override
  Widget build(BuildContext context) {
    //decoration
    Color colorIcon = textGrey;
    Color colorErrorBorder = Colors.red;
    Color colorFocusBorder = textGrey;
    Color colorEnabledBorder = textGrey;

    TextInputType inpType;

    switch (widget.inputType) {
      case ('name'):
        validator = nameValidator;
        inpType = null;
        break;
      case ('lastName'):
        validator = lastNameValidator;
        inpType = null;
        break;
      case ('password'):
        validator = passwordValidator;
        inpType = null;
        break;
      case ('passwordLogin'):
        validator = passwordLogin;
        inpType = null;
        break;
      case ('email'):
        validator = emailValidator;
        inpType = TextInputType.emailAddress;
        break;
      case ('phone'):
        validator = phoneValidator;
        inpType = TextInputType.visiblePassword;
        break;
      case ('number'):
        validator = genericValidator;
        inpType = TextInputType.visiblePassword;
        break;
      case ('pass'):
        validator = passwordLogin;
        break;
      case ('none'):
        validator = null;
        inpType = null;
        break;
      default:
        validator = genericValidator;
        break;
    }
    return TextFormField(
      textCapitalization: widget.textCapitalization,
      enabled: widget.enabled ? true : false,
      key: widget.fieldKey,
      obscureText: widget.inputType == 'password' ||
              widget.inputType == 'passwordConfirm' ||
              widget.inputType == 'passwordLogin' ||
              widget.inputType == 'pass'
          ? _obscureText
          : false,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      validator: validator,
      keyboardType: inpType,
      inputFormatters: widget.inputType == 'phone' ||
              widget.inputType == 'number' ||
              widget.inputType == 'card_number'
          ? [
              // DecimalTextInputFormatter(),
              FilteringTextInputFormatter(RegExp("[0-9 .]"), allow: true)
            ]
          : null,
      // onFieldSubmitted: widget.onFieldSubmitted,
      initialValue: widget.initValue,
      textInputAction: widget.inpAction,
      onFieldSubmitted: (_) => widget.inpAction == TextInputAction.next
          ? FocusScope.of(context).nextFocus()
          : null,
      decoration: InputDecoration(
        suffixIcon: widget.inputType == 'password' ||
                widget.inputType == 'passwordConfirm' ||
                widget.inputType == 'passwordLogin'
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: colorIcon),
              )
            : Icon(
                widget.icon,
                color: widget.mainColor == null ? colorIcon : textGrey,
              ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Colors.black38,
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: Colors.black54,
          fontSize: 15,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: widget.mainColor == null
                  ? colorEnabledBorder
                  : widget.mainColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorFocusBorder),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorErrorBorder),
        ),
        errorStyle: TextStyle(color: colorErrorBorder),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorErrorBorder),
        ),
      ),
    );
  }
}

class DropDownAddField extends StatefulWidget {
  const DropDownAddField(
      {this.fbKey,
      this.attribute,
      this.labelText,
      this.initValue,
      this.itemsList,
      this.onChanged,
      this.validator,
      this.enabled});

  final GlobalKey fbKey;
  final String initValue;
  final String attribute, labelText;
  final List<String> itemsList;
  final FormFieldSetter<String> onChanged;
  final Function validator;
  final bool enabled;

  @override
  _DropDownAddFieldState createState() => _DropDownAddFieldState();
}

class _DropDownAddFieldState extends State<DropDownAddField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField<String>(
              key: widget.fbKey,
              iconEnabledColor: textGrey,
              decoration: InputDecoration(
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  errorStyle: TextStyle(color: Colors.red),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: textGrey,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  labelText: widget.labelText,
                  labelStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  )),
              value: widget.initValue,
              isExpanded: true,
              items: widget.itemsList.map((String value) {
                return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(
                      value,
                      style: TextStyle(color: textGrey),
                    ));
              }).toList(),
              onChanged: (_) {},
              onSaved: widget.onChanged,
              validator: (value) =>
                  value == null ? 'Este campo es requerido' : null,
            ),
          ),
        ),

        /*     DropdownButtonFormField<String>(

          value: widget.initValue,
          decoration: InputDecoration(
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorStyle: TextStyle(color: Colors.white),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              labelText: widget.labelText,
              labelStyle: TextStyle(
                fontSize: 17,
                color: Colors.white,
              )),
          isExpanded: true,
          onChanged: widget.onChanged,
          items: <String>['A', 'B', 'C', 'D']
                                .map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
          validator: (value) =>
              value == null ? 'Este campo es requerido' : null,
        ), */
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}

class RoundTextField extends StatefulWidget {
  const RoundTextField(
      {this.fieldKey,
      @required this.inputType,
      this.maxLength,
      this.maxLines,
      @required this.enabled,
      this.initValue,
      this.hintText,
      this.labelText,
      this.helperText,
      @required this.onSaved,
      this.onFieldSubmitted,
      this.icon,
      this.textKeyboardType,
      @required this.textCapitalization,
      this.context,
      this.inpAction,
      @required this.mainColor,
      this.onChanged,
      this.colorIcon,
      this.colorErrorBorder,
      this.colorFocusBorder,
      this.colorEnabledBorder,
      this.colorText,
      this.colorlabelText,
      this.colorhintText});

  final BuildContext context;
  final Key fieldKey;
  final int maxLength;
  final int maxLines;
  final bool enabled;
  final String initValue;
  final String inputType;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> onChanged;
  final ValueChanged<String> onFieldSubmitted;
  final IconData icon;
  final TextInputType textKeyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction inpAction;
  final Color mainColor;
  final Color colorIcon;
  final Color colorErrorBorder;
  final Color colorFocusBorder;
  final Color colorEnabledBorder;
  final Color colorText;
  final Color colorlabelText;
  final Color colorhintText;

  @override
  _RoundTextFieldState createState() => _RoundTextFieldState();
}

class _RoundTextFieldState extends State<RoundTextField> {
  bool _obscureText = true;
  var validator = genericValidator;

  @override
  Widget build(BuildContext context) {
    //decoration
    Color colorIcon = Colors.white;
    Color colorErrorBorder = Colors.red;

    TextInputType inpType;

    switch (widget.inputType) {
      case ('name'):
        validator = nameValidator;
        inpType = null;
        break;
      case ('lastName'):
        validator = lastNameValidator;
        inpType = null;
        break;
      case ('password'):
        validator = passwordValidator;
        inpType = null;
        break;
      case ('passwordLogin'):
        validator = passwordLogin;
        inpType = null;
        break;
      case ('email'):
        validator = emailValidator;
        inpType = TextInputType.emailAddress;
        break;
      case ('phone'):
        validator = phoneValidator;
        inpType = TextInputType.visiblePassword;
        break;
      case ('number'):
        validator = genericValidator;
        inpType = TextInputType.visiblePassword;
        break;
      case ('none'):
        validator = null;
        inpType = null;
        break;
      default:
        validator = genericValidator;
        break;
    }
    return TextFormField(
      cursorColor: primaryYellow,
      style: TextStyle(
          color:
              widget.colorText == null ? widget.mainColor : widget.colorText),
      textCapitalization: widget.textCapitalization,
      enabled: widget.enabled ? true : false,
      key: widget.fieldKey,
      obscureText: widget.inputType == 'password' ||
              widget.inputType == 'passwordConfirm' ||
              widget.inputType == 'passwordLogin'
          ? _obscureText
          : false,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      validator: validator,
      keyboardType: inpType,
      inputFormatters: widget.inputType == 'phone' ||
              widget.inputType == 'number' ||
              widget.inputType == 'card_number'
          ? [
              // DecimalTextInputFormatter(),
              FilteringTextInputFormatter(RegExp("[0-9 .]"), allow: true)
            ]
          : null,
      // onFieldSubmitted: widget.onFieldSubmitted,
      initialValue: widget.initValue,
      textInputAction: widget.inpAction,
      onFieldSubmitted: (_) => widget.inpAction == TextInputAction.next
          ? FocusScope.of(context).nextFocus()
          : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: widget.inputType == 'password' ||
                widget.inputType == 'passwordConfirm' ||
                widget.inputType == 'passwordLogin'
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: widget.colorIcon == null
                        ? widget.mainColor
                        : widget.colorIcon),
              )
            : Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Hero(
                tag: 'searchIcon',
                child: Icon(
                  widget.icon,
                  // size: 30,
                  color: widget.colorIcon == null
                      ? widget.mainColor
                      : widget.colorIcon,
                ),
              ),
            ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
            color: widget.colorhintText == null
                ? widget.mainColor
                : widget.colorhintText),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: widget.colorlabelText == null
              ? widget.mainColor
              : widget.colorlabelText,
          fontSize: 15,
        ),
        helperText: widget.helperText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
              color: widget.colorEnabledBorder == null
                  ? widget.mainColor
                  : widget.colorEnabledBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
              color: widget.colorFocusBorder == null
                  ? widget.mainColor
                  : widget.colorFocusBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
              color: widget.colorErrorBorder == null
                  ? colorErrorBorder
                  : widget.colorErrorBorder),
        ),
        errorStyle: TextStyle(
            color: widget.colorErrorBorder == null
                ? colorErrorBorder
                : widget.colorErrorBorder),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
              color: Colors.white),
        ),
      ),
    );
  }
}

class BorderTextField extends StatefulWidget {
  const BorderTextField(
      {this.fieldKey,
      @required this.inputType,
      this.maxLength,
      this.maxLines,
      @required this.enabled,
      this.initValue,
      this.hintText,
      this.labelText,
      this.helperText,
      @required this.onSaved,
      this.onFieldSubmitted,
      this.icon,
      this.textKeyboardType,
      @required this.textCapitalization,
      this.context,
      this.inpAction,
      @required this.mainColor,
      this.onChanged,
      this.colorIcon,
      this.colorErrorBorder,
      this.colorFocusBorder,
      this.colorEnabledBorder,
      this.colorText,
      this.colorlabelText,
      this.colorhintText});

  final BuildContext context;
  final Key fieldKey;
  final int maxLength;
  final int maxLines;
  final bool enabled;
  final String initValue;
  final String inputType;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> onChanged;
  final ValueChanged<String> onFieldSubmitted;
  final IconData icon;
  final TextInputType textKeyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction inpAction;
  final Color mainColor;
  final Color colorIcon;
  final Color colorErrorBorder;
  final Color colorFocusBorder;
  final Color colorEnabledBorder;
  final Color colorText;
  final Color colorlabelText;
  final Color colorhintText;

  @override
  _BorderTextFieldState createState() => _BorderTextFieldState();
}

class _BorderTextFieldState extends State<BorderTextField> {
  bool _obscureText = true;
  var validator = genericValidator;

  @override
  Widget build(BuildContext context) {
    //decoration
    Color colorIcon = Colors.grey;
    Color colorErrorBorder = Colors.red;

    TextInputType inpType;

    switch (widget.inputType) {
      case ('name'):
        validator = nameValidator;
        inpType = null;
        break;
      case ('lastName'):
        validator = lastNameValidator;
        inpType = null;
        break;
      case ('password'):
        validator = passwordValidator;
        inpType = null;
        break;
      case ('passwordLogin'):
        validator = passwordLogin;
        inpType = null;
        break;
      case ('email'):
        validator = emailValidator;
        inpType = TextInputType.emailAddress;
        break;
      case ('phone'):
        validator = phoneValidator;
        inpType = TextInputType.visiblePassword;
        break;
      case ('number'):
        validator = genericValidator;
        inpType = TextInputType.visiblePassword;
        break;
      case ('none'):
        validator = null;
        inpType = null;
        break;
      default:
        validator = genericValidator;
        break;
    }
    return TextFormField(
      style: TextStyle(
          color:
              widget.colorText == null ? widget.mainColor : widget.colorText),
      textCapitalization: widget.textCapitalization,
      enabled: widget.enabled ? true : false,
      key: widget.fieldKey,
      obscureText: widget.inputType == 'password' ||
              widget.inputType == 'passwordConfirm' ||
              widget.inputType == 'passwordLogin'
          ? _obscureText
          : false,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      validator: validator,
      keyboardType: inpType,
      inputFormatters: widget.inputType == 'phone' ||
              widget.inputType == 'number' ||
              widget.inputType == 'card_number'
          ? [
              // DecimalTextInputFormatter(),
              FilteringTextInputFormatter(RegExp("[0-9 .]"), allow: true)
            ]
          : null,
      // onFieldSubmitted: widget.onFieldSubmitted,
      initialValue: widget.initValue,
      textInputAction: widget.inpAction,
      onFieldSubmitted: (_) => widget.inpAction == TextInputAction.next
          ? FocusScope.of(context).nextFocus()
          : null,
      decoration: InputDecoration(
        suffixIcon: widget.inputType == 'password' ||
                widget.inputType == 'passwordConfirm' ||
                widget.inputType == 'passwordLogin'
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: widget.colorIcon == null
                        ? widget.mainColor
                        : widget.colorIcon),
              )
            : Icon(
                widget.icon,
                color: widget.colorIcon == null
                    ? widget.mainColor
                    : widget.colorIcon,
              ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
            color: widget.colorhintText == null
                ? widget.mainColor
                : widget.colorhintText),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: widget.colorlabelText == null
              ? widget.mainColor
              : widget.colorlabelText,
          fontSize: 15,
        ),
        helperText: widget.helperText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: widget.colorEnabledBorder == null
                  ? widget.mainColor
                  : widget.colorEnabledBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: widget.colorFocusBorder == null
                  ? widget.mainColor
                  : widget.colorFocusBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: widget.colorErrorBorder == null
                  ? colorErrorBorder
                  : widget.colorErrorBorder),
        ),
        errorStyle: TextStyle(
            color: widget.colorErrorBorder == null
                ? colorErrorBorder
                : widget.colorErrorBorder),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: widget.colorErrorBorder == null
                  ? colorErrorBorder
                  : widget.colorErrorBorder),
        ),
      ),
    );
  }
}
