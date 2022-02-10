import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/widgets/button_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';
import 'dart:html' as html;

import '../global.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AdminModel adminModel = AdminModel();
  VerdeService verdeService = VerdeService();
  var tokenUser;

  @override
  Widget build(context) =>
      Scaffold(body: LayoutBuilder(builder: (context, constraints) {
        MediaQueryData queryData = MediaQuery.of(context);
        return Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[600],
                  blurRadius: 20.0, // has the effect of softening the shadow
                  spreadRadius: 0, // has the effect of extending the shadow
                  // offset: Offset(
                  //   10.0, // horizontal, move right 10
                  //   10.0, // vertical, move down 10
                  // ),
                )
              ],
              image: DecorationImage(
                  colorFilter:
                      new ColorFilter.mode(Colors.black, BlendMode.dstATop),
                  // image: NetworkImage(
                  //   'https://images8.alphacoders.com/568/thumb-1920-568408.jpg',
                  // ),
                  image: AssetImage('images/bgCover.jpg'),
                  fit: BoxFit.cover)),
          child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              color: Colors.transparent,
              padding: constraints.maxWidth < 400
                  ? EdgeInsets.zero
                  : EdgeInsets.all(30.0),
              child: Center(
                child: Container(
                  // padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 25.0),
                  constraints: BoxConstraints(
                    maxWidth: 400,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  //   image: DecorationImage(
                  //       image: AssetImage('images/registroCover.jpg'),
                  //       fit: BoxFit.cover),
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(5.0),
                  // ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                          AssetImage('images/logoVerde.png'))),
                            ),
                            Text(
                              'Iniciar Sesión',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                            SimpleTextField(
                              textCapitalization: TextCapitalization.none,
                              onSaved: (value) => adminModel.correo = value,
                              // initValue: 'zuriel.balabox@gmail.com',
                              inputType: 'email',
                              enabled: true,
                              icon: Icons.mail,
                              labelText: 'Correo',
                              inpAction: TextInputAction.next,
                              mainColor: Colors.black87,
                            ),
                            SimpleTextField(
                              // initValue: '12345678',
                              textCapitalization: TextCapitalization.characters,
                              onSaved: (value) => adminModel.password = value,
                              inputType: 'passwordLogin',
                              enabled: true,
                              inpAction: TextInputAction.next,
                              maxLines: 1,
                              labelText: 'Contraseña',
                              mainColor: Colors.black87,
                            ),
                            ButtonPrimary(
                              mainText: 'Entrar',
                              pressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  verdeService
                                      .postService(adminModel, 'admin/login')
                                      .then((serverResp) {
                                    if (serverResp['status'] == 'server_true') {
                                      var respResponse =
                                          jsonDecode(serverResp['response']);

                                      setState(() {
                                        tokenUser = respResponse[1]['token'];
                                        // print(tokenUser);
                                      });
                                      saveUserToken(tokenUser).then((value) {
                                        saveAdminModel(adminModel)
                                            .then((value) {
                                          Navigator.pushReplacementNamed(
                                              context, "/home");
                                        });
                                      });
                                    } else {
                                      var respResponse =
                                          jsonDecode(serverResp['response']);
                                      dialog(false, context,
                                          respResponse['message'].toString());
                                    }
                                  });
                                }
                              },
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {
                                  html.window.location.href =
                                      "https://merkadoverdeapp.com/blog/";
                                },
                                child: Text(
                                  '¿No eres administrador?, Ingresa aqui',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              )),
        );
      }));
}

class _HeaderCurvoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Propiedades
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 5.0;

    final path = Path();

    // Dibujar path
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.3);
    // path.lineTo(0, size.height * 0.9);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.4, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);

    final paintCircle = Paint();

    // Propiedades
    paintCircle.color = Colors.white;
    paintCircle.style = PaintingStyle.fill;
    paintCircle.strokeWidth = 5.0;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
