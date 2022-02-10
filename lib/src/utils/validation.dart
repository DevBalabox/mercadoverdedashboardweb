import 'package:form_field_validator/form_field_validator.dart';

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Ingresa tu contraseña'),
  // MinLengthValidator(8, errorText: 'Contraseña muy corta'),
]);

final passwordLogin = MultiValidator([
  RequiredValidator(errorText: 'Ingresa tu contraseña'),
  // PatternValidator(r'(?=.*?[#?!@$%^&*-])',
  //     errorText: 'passwords must have at least one special character'),
]);

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Ingresa tu correo'),
  EmailValidator(errorText: 'Ingresa un correo válido')
]);

final phoneValidator = MultiValidator([
  RequiredValidator(errorText: 'Ingresa tu teléfono'),
  MinLengthValidator(7, errorText: 'Ingresa tu teléfono'),
]);

final nameValidator = MultiValidator([
  RequiredValidator(errorText: 'Ingresa tu nombre'),
  MinLengthValidator(3, errorText: 'Ingresa tu nombre'),
]);

final lastNameValidator = MultiValidator([
  RequiredValidator(errorText: 'Ingresa tu apellido'),
  MinLengthValidator(3, errorText: 'Ingresa tu apellido'),
]);

final genericValidator = MultiValidator([
  RequiredValidator(errorText: 'Es necesario completar este campo'),
]);
