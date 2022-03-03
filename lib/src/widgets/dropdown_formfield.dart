import 'package:flutter/material.dart';

class DropDownFormField extends FormField<dynamic> {
  final titleText;
  final hintText;
  final require;
  final errorText;
  final value;
  final dataSource;
  final textField;
  final valueField;
  final onChanged;
  final filled;
  final contentPadding;

  DropDownFormField(
      {FormFieldSetter<dynamic> onSaved,
      FormFieldValidator<dynamic> validator,
      AutovalidateMode autovalidate = AutovalidateMode.disabled,
      String this.titleText = 'Title',
      String this.hintText = 'Select one option',
      bool this.require = false,
      String this.errorText = 'Please select one option',
      dynamic this.value,
      List this.dataSource,
      String this.textField,
      String this.valueField,
      Function this.onChanged,
      bool this.filled = true,
      EdgeInsets this.contentPadding = const EdgeInsets.fromLTRB(12, 12, 8, 0)})
      : super(
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidate,
          initialValue: value == '' ? '' : value,
          builder: (FormFieldState<dynamic> state) {
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: contentPadding,
                      labelText: titleText,
                      filled: filled,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        isExpanded: true,
                        hint: Text(
                          hintText,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        value: value == '' ? null : value,
                        onChanged: (dynamic newValue) {
                          state.didChange(newValue);
                          onChanged(newValue);
                        },
                        items: dataSource.map((item) {
                          return DropdownMenuItem<dynamic>(
                            value: item[valueField],
                            child: Text(item[textField],
                                overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: state.hasError ? 5.0 : 0.0),
                  //Text(
                  //  state.hasError ? state.errorText : '',
                  //  style: TextStyle(
                  //      color: Colors.redAccent.shade700,
                  //      fontSize: state.hasError ? 12.0 : 0.0),
                  //),
                ],
              ),
            );
          },
        );
}
