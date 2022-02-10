import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_verde/src/global.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/button_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';
import 'dart:html' as html;

class PasswordPage extends StatefulWidget {
  final String token;
  final String mail;
  PasswordPage({Key key, this.token, this.mail}) : super(key: key);

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage>
    with TickerProviderStateMixin {
  VerdeService verdeService = VerdeService();
  bool load = true;
  bool tokenOK = false;
  var jsonResp;
  var newPass;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AnimationController animationController;

  bool _isSearching;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
    getInit();
    super.initState();
  }

  getInit() async {
    try {
      await verdeService
          .getService(
              null,
              'restore-password?correo=${widget.mail}&token=${widget.token}',
              null)
          .then((serverResp) {
        // print(serverResp);
        if (serverResp['status'] == 'server_true') {
          setState(() {
            load = false;
            tokenOK = true;
            jsonResp = jsonDecode(serverResp['response']);
          });
        } else {
          setState(() {
            load = false;
            tokenOK = false;
          });
        }
      });
    } catch (e) {
      // print(e.toString());
      setState(() {
        load = false;
        tokenOK = false;
      });
    }
  }

  postPassword() async {
    var jsonBody = {
      "token": widget.token,
      "usuario_id": jsonResp[1]['user_id'].toString(),
      "password": newPass
    };
    await verdeService
        .postTokenService(jsonBody, 'restore-password', null)
        .then((serverResp) {
      // print(serverResp);
      var respResponse = jsonDecode(serverResp['response']);
      if (serverResp['status'] == 'server_true') {
        dialog(true, context, respResponse['message'].toString());
      } else {
        dialog(false, context, respResponse['message'].toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return load
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: primaryGreen,
              leading: null,
              automaticallyImplyLeading: false,
              title: InkWell(
                onTap: () => html.window.location.href =
                    "https://merkadoverdeapp.com/blog/",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/isoBlanco.png',
                      fit: BoxFit.contain,
                      width: 50,
                    ),
                    Image.asset(
                      'images/nameLogo.png',
                      fit: BoxFit.contain,
                      width: 170,
                    ),
                  ],
                ),
              ),
            ),
            body: Align(
                alignment: Alignment.center,
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: primaryGreen,
                    valueColor: animationController.drive(
                        ColorTween(begin: primaryOrange, end: primaryYellow)),
                  ),
                )),
          )
        : !tokenOK
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: primaryGreen,
                  leading: null,
                  automaticallyImplyLeading: false,
                  title: InkWell(
                    onTap: () => html.window.location.href =
                        "https://merkadoverdeapp.com/blog/",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/isoBlanco.png',
                          fit: BoxFit.contain,
                          width: 50,
                        ),
                        Image.asset(
                          'images/nameLogo.png',
                          fit: BoxFit.contain,
                          width: 170,
                        ),
                      ],
                    ),
                  ),
                ),
                body: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mood_bad,
                        size: 35,
                      ),
                      Text(
                        'No se encontro una solicitud para cambiar contraseña',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              )
            : Scaffold(
              appBar: AppBar(
                  backgroundColor: primaryGreen,
                  leading: null,
                  automaticallyImplyLeading: false,
                  title: InkWell(
                    onTap: () => html.window.location.href =
                        "https://merkadoverdeapp.com/blog/",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/isoBlanco.png',
                          fit: BoxFit.contain,
                          width: 50,
                        ),
                        Image.asset(
                          'images/nameLogo.png',
                          fit: BoxFit.contain,
                          width: 170,
                        ),
                      ],
                    ),
                  ),
                ),
                body: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width > 500
                          ? MediaQuery.of(context).size.width / 2.5
                          : MediaQuery.of(context).size.width / 1.2,
                      height: MediaQuery.of(context).size.height / 1.2,
                      padding: EdgeInsets.all(35),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.7),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/logoVerde.png',
                              fit: BoxFit.contain,
                              width: 170,
                            ),
                            Text(
                              'Recuperar contraseña',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: primaryGreen,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.mail.toString(),
                              style: TextStyle(color: textGrey, fontSize: 17),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SimpleTextField(
                                labelText: 'Nueva contraseña',
                                inputType: 'password',
                                enabled: true,
                                onSaved: (value) => newPass = value,
                                maxLines: 1,
                                textCapitalization: TextCapitalization.none),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ButtonPrimary(
                                    mainText: 'Aceptar',
                                    pressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();
                                        postPassword();
                                      }
                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )),
              );
  }
}
