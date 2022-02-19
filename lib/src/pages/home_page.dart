import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/pages/announcements_page.dart';
import 'package:web_verde/src/pages/category_page.dart';
import 'package:web_verde/src/pages/client_page.dart';
import 'package:web_verde/src/pages/create_announcement.dart';
import 'package:web_verde/src/pages/servicio_page.dart';
import 'package:web_verde/src/pages/vendedor_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/globals_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';

import '../global.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.rutaSeleccionada, this.labelInit}) : super(key: key);

  final dynamic rutaSeleccionada;
  final String labelInit;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool login = false;
  dynamic pageSelect = Client();
  String pageTitle;
  dynamic initRuta;

  bool closeBar = false;

  @override
  void initState() {
    sharedPrefs.init();

    if (sharedPrefs.clientToken == "") {
      Navigator.pushReplacementNamed(context, "/login");
    }
    initRuta = widget.rutaSeleccionada;
    pageTitle = widget.labelInit == null ? 'Clientes' : widget.labelInit;
    // if(sharedPrefs.clientToken == '' || sharedPrefs.clientToken == null){
    //   Navigator.pushReplacementNamed(context, "/login");
    // } else{
    //   setState(() {
    //     login = true;
    //   });
    // }
    super.initState();
  }

  @override
  Widget build(context) => Scaffold(
        appBar: MediaQuery.of(context).size.width < 500
            ? AppBar(
                leading: null,
                // automaticallyImplyLeading: false,
                backgroundColor: primaryGreen,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Text(pageTitle.toUpperCase()),
                    Flexible(
                      child: InkWell(
                          onTap: () => _displayDialog(context),
                          child: Text(
                            'Bienvenido, administrador',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 10),
                          )),
                    ),
                    // FlatButton(
                    //   padding: EdgeInsets.all(0),
                    //   color: Colors.white,
                    //   onPressed: () {
                    // logoutUser().then((value) =>
                    //     Navigator.pushReplacementNamed(context, "/login"));
                    //   },
                    //   child: Icon(
                    //     Icons.logout,
                    //     color: primaryGreen,
                    //   ),
                    // ),
                  ],
                ),
                // title: Row(children: [
                //   Icon(Icons.ac_unit),
                //   SizedBox(width: 10),
                //   Text('Bienvenido, Tom')
                // ]),
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () => logoutUser().then((value) =>
                        Navigator.pushReplacementNamed(context, "/login")),
                  )
                ],
              )
            : AppBar(
                leading: null,
                automaticallyImplyLeading: false,
                backgroundColor: primaryGreen,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Container(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Text(pageTitle.toUpperCase())),

                    InkWell(
                        onTap: () => _displayDialog(context),
                        child: Text(
                          'Bienvenido, administrador',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 17),
                        )),

                    Align(
                      alignment: Alignment.center,
                      child: Row(
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
                    Container(
                      height: 10,
                    )
                    // FlatButton(
                    //   color: Colors.white,
                    //   onPressed: () {
                    //     logoutUser().then((value) =>
                    //         Navigator.pushReplacementNamed(context, "/login"));
                    //   },
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         Icons.logout,
                    //         color: primaryGreen,
                    //       ),
                    //       Text(
                    //         "Cerrar sesión",
                    //         style: TextStyle(color: primaryGreen),
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () => logoutUser().then((value) =>
                        Navigator.pushReplacementNamed(context, "/login")),
                  )
                ],
              ),
        drawer: MediaQuery.of(context).size.width < 500
            ? Drawer(
                child: Container(color: primaryGreen, child: menu()),
              )
            : null,
        body: SafeArea(
            child: Center(
                child: MediaQuery.of(context).size.width < 500 || closeBar
                    ? Container(
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width - 70.0,
                        child: initRuta == null ? pageSelect : initRuta)
                    : Row(children: [
                        Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    colors: [
                                  Color(0xff4BC858),
                                  Color(0xff42AB4E),
                                ])),
                            width: 70.0,
                            child: menuSmall()),
                        Container(
                            color: Colors.grey[200],
                            width: MediaQuery.of(context).size.width - 70.0,
                            child: initRuta == null ? pageSelect : initRuta)
                      ]))),
      );

  menu() {
    return Column(children: [
      SizedBox(height: 25),
      MediaQuery.of(context).size.width < 500
          ? Container(
              height: 100,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/logoBlanco.png'))),
            )
          : Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() {
                        closeBar = !closeBar;
                      })),
            ),
      SizedBox(height: 25),
      FlatButton(
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = Client();
              pageTitle = 'Clientes';
            });
          },
          child: ListTile(
            leading: Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
            ),
            title: Text(
              "Clientes",
              style: TextStyle(color: Colors.white),
            ),
          )),
      FlatButton(
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = Vendedor();
              pageTitle = 'Vendedores';
            });
          },
          child: ListTile(
            leading: Icon(Icons.supervised_user_circle_outlined,
                color: Colors.white),
            title: Text(
              "Vendedores",
              style: TextStyle(color: Colors.white),
            ),
          )),
      FlatButton(
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = ServicePage();
              pageTitle = 'Servicios';
            });
          },
          child: ListTile(
            leading: Icon(Icons.miscellaneous_services, color: Colors.white),
            title: Text(
              "Servicios",
              style: TextStyle(color: Colors.white),
            ),
          )),
      FlatButton(
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = CategoryPage();
              pageTitle = 'Categorías';
            });
          },
          child: ListTile(
            leading: Icon(Icons.category_outlined, color: Colors.white),
            title: Text(
              "Categorias",
              style: TextStyle(color: Colors.white),
            ),
          )),
      // Align(
      //   alignment: Alignment.bottomLeft,
      //   child: FlatButton(
      //       onPressed: () {
      //         Navigator.pushReplacementNamed(context, "/login");
      //       },
      //       child: ListTile(
      //         leading: Icon(Icons.exit_to_app, color: Colors.white),
      //         title: Text(
      //           "Cerrar sesión",
      //           style: TextStyle(color: Colors.white),
      //         ),
      //       )),
      // )
    ]);
  }

  menuSmall() {
    return Column(children: [
      SizedBox(height: 50),
      // MediaQuery.of(context).size.width < 500
      //     ? Container(
      //         height: 100,
      //         decoration: BoxDecoration(
      //             image: DecorationImage(
      //                 image: AssetImage('images/logoBlanco.png'))),
      //       )
      //     : IconButton(
      //         icon: Icon(
      //           Icons.keyboard_arrow_right,
      //           color: Colors.white,
      //         ),
      //         onPressed: () => setState(() {
      //               closeBar = !closeBar;
      //             })),
      // SizedBox(height: 25),
      Tooltip(
        message: 'Clientes',
        child: IconButton(
          icon: Icon(
            Icons.account_circle_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = Client();
              pageTitle = 'Clientes';
            });
          },
        ),
      ),
      Tooltip(
        message: 'Vendedor',
        child: IconButton(
          icon:
              Icon(Icons.supervised_user_circle_outlined, color: Colors.white),
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = Vendedor();
              pageTitle = 'Vendedores';
            });
          },
        ),
      ),
      Tooltip(
        message: 'Servicios',
        child: IconButton(
          icon: Icon(Icons.miscellaneous_services, color: Colors.white),
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = ServicePage();
              pageTitle = 'Servicios';
            });
          },
        ),
      ),
      Tooltip(
        message: 'Categorías',
        child: IconButton(
          icon: Icon(Icons.category_outlined, color: Colors.white),
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = CategoryPage();
              pageTitle = 'Categorías';
            });
          },
        ),
      ),
      Tooltip(
        message: 'Anuncios',
        child: IconButton(
          icon: Icon(Icons.volume_up, color: Colors.white),
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = AnnouncementsPage();
              pageTitle = 'Anuncios';
            });
          },
        ),
      ),
      Tooltip(
        message: 'Anuncios',
        child: IconButton(
          icon: Icon(Icons.volume_up, color: Colors.white),
          onPressed: () {
            setState(() {
              initRuta = null;
              pageSelect = CreateAnnouncement();
              pageTitle = 'crear';
            });
          },
        ),
      ),
    ]);
  }

  _displayDialog(BuildContext context) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    VerdeService verdeService = VerdeService();
    AdminModel adminModel = AdminModel();
    String userPass;
    String newPass;

    bool valPass = false;
    bool valOk = false;

    String textMessage;

    var jsonChangePass;

    String error;

    postConfirmPassword() {
      setState(() {
        jsonChangePass = {"password": newPass};
        var jsonUser = jsonDecode(sharedPrefs.adminUserData);
        adminModel = AdminModel.fromJson(jsonUser);
        adminModel.password = userPass;
      });
      verdeService.postService(adminModel, "admin/login").then((serverResp) {
        var respResp = jsonDecode(serverResp['response']);

        if (serverResp['status'] == 'server_true') {
          verdeService
              .postTokenService(
                  jsonChangePass, "cambiar-clave", sharedPrefs.clientToken)
              .then((serverResp) {
            if (serverResp['status'] == 'server_true') {
              var respResponse = jsonDecode(serverResp['response']);
              textMessage = respResponse['message'];
              Navigator.pop(context);
              dialog(true, context, respResponse['message']).toString();
              // messageToUser(_scaffoldKey, textMessage);
            } else {
              var respResponse = jsonDecode(serverResp['response']);
              textMessage = respResponse['message'];
              Navigator.pop(context);
              dialog(false, context, respResponse['message']).toString();
              // messageToUser(_scaffoldKey, textMessage);
            }
          });
        } else {
          setState(() {
            var respResponse = jsonDecode(serverResp['response']);
            textMessage = respResponse['message'];
            setState(() {
              error = respResponse['message'];
            });
            dialog(false, context, respResp['message']).toString();
            // Navigator.pop(context);
            // messageToUser(_scaffoldKey, textMessage);
          });
        }
      });
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              scrollable: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              contentPadding: EdgeInsets.only(top: 50.0),
              content: Container(
                width: MediaQuery.of(context).size.width / 3,
                // height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            "Cambiar contraseña",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24.0,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: valOk
                            ? Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Center(child: Text(textMessage))
                                ],
                              )
                            : Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    valPass
                                        ? SizedBox(
                                            height: 15,
                                          )
                                        : Container(),
                                    valPass ? Text(textMessage) : Container(),
                                    SimpleTextField(
                                      labelText: 'Contraseña actual',
                                      inpAction: TextInputAction.next,
                                      inputType: 'password',
                                      enabled: true,
                                      onSaved: (value) => userPass = value,
                                      textCapitalization:
                                          TextCapitalization.none,
                                      mainColor: textGrey,
                                      maxLines: 1,
                                    ),
                                    SimpleTextField(
                                        maxLines: 1,
                                        labelText: 'Nueva contraseña',
                                        inpAction: TextInputAction.done,
                                        inputType: 'password',
                                        enabled: true,
                                        onSaved: (value) => newPass = value,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        mainColor: textGrey),
                                  ],
                                ),
                              )),
                    error == null ? Container() : Text(error),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          valOk
                              ? Container()
                              : Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(100),
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.1),
                                              blurRadius:
                                                  5.0, // soften the shadow
                                              spreadRadius:
                                                  1.0, //extend the shadow
                                              offset: Offset(
                                                0.0, // Move to right 10  horizontally
                                                3.0, // Move to bottom 10 Vertically
                                              ),
                                            )
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          // gradient: gradientGreen,
                                          color: primaryOrange),
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        alignment: Alignment.center,
                                        // height: 50.0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              child: Flexible(
                                                child: Text(
                                                  'Cancelar',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // color: Colors.white,
                                    ),
                                  ),
                                ),
                          SizedBox(height: 20),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              // onTap: () => Navigator.of(context).pop(),
                              onTap: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  postConfirmPassword();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.1),
                                      blurRadius: 5.0, // soften the shadow
                                      spreadRadius: 1.0, //extend the shadow
                                      offset: Offset(
                                        0.0, // Move to right 10  horizontally
                                        3.0, // Move to bottom 10 Vertically
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(100),
                                  // gradient: gradientGreen,
                                  color: primaryGreen,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  alignment: Alignment.center,
                                  // height: 50.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Flexible(
                                          child: Text(
                                            valOk ? 'Aceptar' : 'Cambiar',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}
