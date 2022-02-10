import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:jiffy/jiffy.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/model/user_model.dart';
import 'package:web_verde/src/pages/home_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/button_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';

import '../global.dart';

////// Data class.
class User {
  User(
      this.nombre,
      this.primer_apellido,
      this.segundo_apellido,
      this.correo,
      this.telefono,
      this.ubicacion,
      this.img_url,
      this.usuario_id,
      this.created_at,
      this.updated_at,
      this.deleted_at);
  final String img_url;
  final String nombre;
  final String primer_apellido;
  final String segundo_apellido;
  final String correo;
  final String telefono;
  final String ubicacion;
  final String usuario_id;
  final String created_at;
  final String updated_at;
  final String deleted_at;
}

class Client extends StatefulWidget {
  @override
  _ClientState createState() => _ClientState();
}

class _ClientState extends State<Client> with TickerProviderStateMixin {
  var jsonUser;
  List<User> userData = [];
  List<User> searchList = [];

  VerdeService verdeService = VerdeService();
  AdminModel adminModel = AdminModel();
  bool loadInfo = true;
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
    // print(sharedPrefs.clientToken.toString());

    getUser().then((value) {
      for (var i = 0; i < jsonUser.length; i++) {
        userData.add(User(
            jsonUser[i]['nombre'],
            jsonUser[i]['primer_apellido'],
            jsonUser[i]['segundo_apellido'],
            jsonUser[i]['correo'],
            jsonUser[i]['telefono'],
            jsonUser[i]['ubicacion'],
            jsonUser[i]['img_url'],
            jsonUser[i]['usuario_id'],
            jsonUser[i]['created_at'],
            jsonUser[i]['updated_at'],
            jsonUser[i]['deleted_at']));
      }
      setState(() {
        loadInfo = false;
      });
    });

    super.initState();
  }

  getUser() async {
    sharedPrefs.init();
    print(sharedPrefs.clientToken);
    await verdeService
        .getService(
            adminModel, 'usuarios?tipo=cliente', sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        setState(() {
          jsonUser = respResponse[1];
        });
      }
    });
  }

  void searchOperation(String searchText) {
    searchList.clear();
    _handleSearchStart();
    if (_isSearching != null) {
      for (int i = 0; i < userData.length; i++) {
        String dataNombre = userData[i].nombre;
        String dataPApellido = userData[i].primer_apellido;
        String dataSApellido = userData[i].segundo_apellido;
        String dataCorreo = userData[i].correo;
        String dataTelefono = userData[i].telefono;
        String dataUbicacion = userData[i].ubicacion;
        if (dataNombre.toLowerCase().contains(searchText.toLowerCase()) ||
            dataPApellido.toLowerCase().contains(searchText.toLowerCase()) ||
            dataSApellido.toLowerCase().contains(searchText.toLowerCase()) ||
            dataCorreo.toLowerCase().contains(searchText.toLowerCase()) ||
            dataTelefono.toLowerCase().contains(searchText.toLowerCase()) ||
            dataUbicacion.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            searchList.add(userData[i]);
          });
        }
      }
    }
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  @override
  Widget build(context) {
    int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
    return loadInfo
        ? Center(
            child: CircularProgressIndicator(
              backgroundColor: primaryGreen,
              valueColor: animationController
                  .drive(ColorTween(begin: primaryOrange, end: primaryYellow)),
            ),
          )
        : userData.length == 0
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(
                    //   height: queryData.size.height / 2.7,
                    // ),
                    Icon(
                      Icons.do_not_disturb_alt,
                      color: Colors.black.withOpacity(0.5),
                      size: 35,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'No se encontraron clientes',
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    )
                  ],
                ),
              )
            : ListView(
                children: [
                  SingleChildScrollView(
                      child: PaginatedDataTable(
                    // header: const Text('Clientes'),
                    header: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MediaQuery.of(context).size.width < 700
                            ? Container()
                            : Expanded(
                                flex: 1,
                                child: Text(
                                  'CLIENTES',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: primaryGreen,
                                      fontSize: 25),
                                ),
                              ),
                        Expanded(
                          flex: 4,
                          child: RoundTextField(
                            hintText: 'Búscar...',
                            colorhintText: textGrey,
                            colorText: textGrey,
                            colorIcon: primaryGreen,
                            mainColor: Colors.white,
                            maxLines: 1,
                            enabled: true,
                            onSaved: (value){},
                            inputType: 'generic',
                            textCapitalization: TextCapitalization.sentences,
                            icon: Icons.search,
                            onChanged: (value) => searchOperation(value),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      MediaQuery.of(context).size.width < 200
                          ? Container()
                          : Tooltip(
                              message: 'Enviar notificación',
                              child: Container(
                                padding: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  color: primaryYellow,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                    icon: Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _notDialog(context)),
                              ),
                            )
                    ],
                    showCheckboxColumn: false,
                    // rowsPerPage: _rowsPerPage,
                    availableRowsPerPage: const <int>[10],
                    // onRowsPerPageChanged: (int value) {
                    //   setState(() {
                    //     _rowsPerPage = value;
                    //   });
                    // },
                    columns: kTableColumns,
                    source: DessertDataSource(
                        dataUser:
                            searchList.length == 0 ? userData : searchList,
                        mycontext: context),

                    //   ),
                    //  ) ]
                  ))
                ],
              );
  }

  Future<void> _notDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return NotificationDialog();
        });
  }
}

class NotificationDialog extends StatefulWidget {
  NotificationDialog({Key key}) : super(key: key);

  @override
  _NotificationDialogState createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String titulo;
  String mensaje;
  VerdeService verdeService = VerdeService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Enviar notificación a clientes',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black87),
                  // textAlign: TextAlign.center,7
                ),
              ),
              IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context))
            ],
          ),
          Divider(
            color: primaryGreen.withOpacity(0.7),
            thickness: 2,
          ),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width / 3,
        child: SingleChildScrollView(
          child: ListBody(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SimpleTextField(
                                  labelText: 'Título',
                                  inputType: 'generic',
                                  enabled: true,
                                  onSaved: (value) => titulo = value,
                                  textCapitalization:
                                      TextCapitalization.sentences),
                              SimpleTextField(
                                  labelText: 'Mensaje',
                                  inputType: 'generic',
                                  enabled: true,
                                  onSaved: (value) => mensaje = value,
                                  textCapitalization:
                                      TextCapitalization.sentences),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ButtonPrimary(
                          mainText: 'Enviar',
                          pressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              // print(titulo + mensaje);
                              sendNot();
                            }
                          })
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
      // content: Container(
      //   width: MediaQuery.of(context).size.width / 3,
      //   child: SingleChildScrollView(
      //       child: new ListBody(
      //     children: <Widget>[
      //       Column(
      //         children: [
      //           Column(
      //             children: [
      //               Row(
      //                 children: [
      //                   Expanded(
      //                     child: Form(
      //                       key: _formKey,
      //                       child: Column(
      //                         children: [
      //                           SimpleTextField(
      //                               labelText: 'Título',
      //                               inputType: 'generic',
      //                               enabled: true,
      //                               onSaved: (value) => titulo = value,
      //                               textCapitalization:
      //                                   TextCapitalization.sentences),
      //                           SimpleTextField(
      //                               labelText: 'Mensaje',
      //                               inputType: 'generic',
      //                               enabled: true,
      //                               onSaved: (value) => mensaje = value,
      //                               textCapitalization:
      //                                   TextCapitalization.sentences),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               SizedBox(
      //                 height: 20,
      //               ),
      //               Row(
      //                 mainAxisAlignment: MainAxisAlignment.end,
      //                 children: [
      //                   ButtonPrimary(
      //                       mainText: 'Enviar',
      //                       pressed: () {
      //                         if (_formKey.currentState.validate()) {
      //                           _formKey.currentState.save();
      //                           print(titulo + mensaje);
      //                           sendNot();
      //                         }
      //                       })
      //                 ],
      //               )
      //             ],
      //           ),
      //         ],
      //       )
      //     ],
      //   )),
      // ),
    );
  }

  sendNot() async {
    var jsonBody = {
      "titulo": titulo,
      "mensaje": mensaje,
      "tipo_usuario": "cliente"
    };
    await verdeService
        .postTokenService(jsonBody, 'notificar', sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      dialog(false, context, respResponse['message']).toString();
      if (serverResp['status'] == 'server_true') {
        Navigator.pop(context);
        dialog(true, context, respResponse['message']).toString();
      } else {
        Navigator.pop(context);
        dialog(false, context, respResponse['message']).toString();
      }
    });
  }
}

////// Columns in table.
const kTableColumns = <DataColumn>[
  DataColumn(
    label: Text(
      '',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Status',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Nombre',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
      label: Text(
    'Primer Apellido',
    style: TextStyle(fontWeight: FontWeight.w700),
  )
      // tooltip: 'The total amount of food energy in the given serving size.',
      // numeric: true,
      ),
  DataColumn(
      label: Text(
    'Segundo Apellido',
    style: TextStyle(fontWeight: FontWeight.w900),
  )),
  DataColumn(
      label: Text(
    'Correo',
    style: TextStyle(fontWeight: FontWeight.w700),
  )),
  DataColumn(
      label: Text(
    'Teléfono',
    style: TextStyle(fontWeight: FontWeight.w700),
  )),
  DataColumn(
      label: Text(
    'Ubicación',
    style: TextStyle(fontWeight: FontWeight.w700),
  )),
  DataColumn(
      label: Text(
    'Fecha de registro',
    style: TextStyle(fontWeight: FontWeight.w700),
  )),
  DataColumn(
      label: Text(
    'Última actualización',
    style: TextStyle(fontWeight: FontWeight.w700),
  )),
];

////// Data source class for obtaining row data for PaginatedDataTable.
class DessertDataSource extends DataTableSource {
  BuildContext _context;
  dynamic _userData;
  DessertDataSource({
    @required List<User> dataUser,
    BuildContext mycontext,
  })  : _userData = dataUser,
        _context = mycontext,
        assert(userData != null);

  // DessertDataSource({@required User userData}) : _userData = userData;

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);

    if (index >= _userData.length) {
      return null;
    }
    final _user = _userData[index];

    Icon iconStatus;

    if (_userData[index].deleted_at == null) {
      iconStatus = Icon(
        Icons.check,
        color: primaryGreen,
      );
    } else {
      iconStatus = Icon(Icons.close, color: primaryOrange);
    }

    return DataRow.byIndex(
        index: index, // DONT MISS THIS
        onSelectChanged: (bool value) {
          _dialogCall(_context, _user.usuario_id);
        },
        cells: <DataCell>[
          DataCell(CircleAvatar(
            backgroundColor: Colors.grey[400],
            backgroundImage: _user.img_url == null
                ? AssetImage('images/isoBlanco.png')
                : NetworkImage(_user.img_url),
          )),
          DataCell(
            IconButton(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: iconStatus,
                onPressed: () {}),
          ),
          DataCell(Text('${_user.nombre}')),
          DataCell(Text('${_user.primer_apellido}')),
          DataCell(Text('${_user.segundo_apellido}')),
          DataCell(Text('${_user.correo}')),
          DataCell(Text('${_user.telefono}')),
          DataCell(Text('${_user.ubicacion}')),
          DataCell(Text('${_user.created_at}')),
          DataCell(Text('${_user.updated_at}')),
        ]);
  }

  Future<void> _dialogCall(BuildContext context, userId) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return MyDialog(userId: userId);
        });
  }

  @override
  int get rowCount => _userData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class MyDialog extends StatefulWidget {
  MyDialog({Key key, @required this.userId}) : super(key: key);

  final String userId;

  @override
  _MyDialogState createState() => new _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  String imagePath;
  Image image;
  Image pickedImage;
  var base64image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String nombreCat;
  var jsonVendedor;

  bool loadInfo = true;

  bool editP = false;

  VerdeService verdeService = VerdeService();

  UserModel userModel = UserModel();

  // DateTime birthdate = DateTime.now();
  // String birthdate_string =
  //     Jiffy(DateTime.now()).format("dd-MM-yyy").toString();

  var mediaData;

  bool userExist = true;

  @override
  void initState() {
    super.initState();
    getUser();
    sharedPrefs.init();
  }

  getUser() async {
    sharedPrefs.init();
    print(sharedPrefs.clientToken);
    await verdeService
        .getService(null, 'clientes/perfil?id=${widget.userId}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        setState(() {
          jsonVendedor = respResponse[1];
          loadInfo = false;
          // birthdate = DateTime.parse(jsonVendedor['fecha_nacimiento']);
          // birthdate_string = Jiffy(jsonVendedor['fecha_nacimiento'])
          //     .format("dd-MM-yyy")
          //     .toString();
          userModel.fecha_nacimiento = jsonVendedor['fecha_nacimiento'];
        });
      } else {
        setState(() {
          userExist = false;
        });
      }
    });
  }

  // Future<Null> _selectDate(BuildContext context) async {
  //   final DateTime picked = await showDatePicker(
  //       fieldLabelText: 'Ingresa la fecha',
  //       // locale: const Locale("es", "MX"),
  //       helpText: 'selecciona tu fecha de nacimiento',
  //       cancelText: 'Cancelar',
  //       confirmText: 'Ok',
  //       context: context,
  //       initialDate: birthdate,
  //       firstDate: DateTime(1930, 8),
  //       lastDate: DateTime(2101));
  //   if (picked != null && picked != birthdate)
  //     setState(() {
  //       birthdate = picked;
  //       birthdate_string = Jiffy(picked).format("dd-MM-yyy").toString();
  //       userModel.fecha_nacimiento =
  //           Jiffy(picked).format("yyy-MM-dd").toString();
  //     });
  // }

  habUsr() async {
    await verdeService
        .postTokenService(null, 'usuarios/habilitar?id=${widget.userId}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(rutaSeleccionada: Client())),
            (route) => false);
        dialog(true, context, respResponse['message']).toString();
      } else {
        Navigator.pop(context);
        dialog(false, context, respResponse['message'].toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return !userExist
        ? AlertDialog(
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Detalles del cliente',
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black87),
                        // textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context))
                  ],
                ),
                Divider(
                  color: primaryGreen.withOpacity(0.7),
                  thickness: 2,
                ),
              ],
            ),
            content: SingleChildScrollView(
                child: new ListBody(
              children: <Widget>[
                Column(
                  children: [
                    Column(
                      children: [
                        Text('Este usuario se encuentra deshabilitado'),
                        SizedBox(
                          height: 20,
                        ),
                        ButtonPrimary(
                            mainText: 'Habilitar usuario',
                            pressed: () => habUsr()),
                      ],
                    ),
                  ],
                )
              ],
            )),
          )
        : AlertDialog(
            title: MediaQuery.of(context).size.width < 300
                ? Container()
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Detalles del cliente',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black87),
                              // textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context))
                        ],
                      ),
                      Divider(
                        color: primaryGreen.withOpacity(0.7),
                        thickness: 2,
                      ),
                    ],
                  ),
            content: loadInfo
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: primaryGreen,
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: SingleChildScrollView(
                        child: new ListBody(
                      children: <Widget>[
                        Column(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            Column(
                                              children: [
                                                CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor:
                                                      Colors.grey[400],
                                                  backgroundImage: mediaData !=
                                                          null
                                                      ? MemoryImage(
                                                          mediaData.data)
                                                      : jsonVendedor[
                                                                  'img_url'] ==
                                                              null
                                                          ? AssetImage(
                                                              'images/isoBlanco.png')
                                                          : NetworkImage(
                                                              jsonVendedor[
                                                                  'img_url']),
                                                ),
                                                !editP
                                                    ? Container()
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5.0),
                                                        child: ButtonLight(
                                                            mainText:
                                                                'Seleccionar foto',
                                                            pressed: () async {
                                                              await pickImage();
                                                              setState(() {});
                                                            }),
                                                      ),
                                              ],
                                            ),
                                            SimpleTextField(
                                                labelText: 'Nombre',
                                                initValue:
                                                    jsonVendedor['nombre'],
                                                inputType: 'nombre',
                                                enabled: editP,
                                                onSaved: (value) =>
                                                    userModel.nombre = value,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences),
                                            SimpleTextField(
                                                labelText: 'Primer apellido',
                                                initValue: jsonVendedor[
                                                    'primer_apellido'],
                                                inputType: 'generic',
                                                enabled: editP,
                                                onSaved: (value) => userModel
                                                    .primer_apellido = value,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences),
                                            SimpleTextField(
                                                labelText: 'Segundo apellido',
                                                initValue: jsonVendedor[
                                                    'segundo_apellido'],
                                                inputType: 'generic',
                                                enabled: editP,
                                                onSaved: (value) => userModel
                                                    .segundo_apellido = value,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences),
                                            // Container(
                                            //   width: double.infinity,
                                            //   margin: EdgeInsets.only(top: 15),
                                            //   padding: EdgeInsets.all(5),
                                            //   decoration: BoxDecoration(
                                            //       color: Colors.grey[200],
                                            //       borderRadius:
                                            //           BorderRadius.circular(5)),
                                            //   child: InkWell(
                                            //       onTap: () {
                                            //         editP
                                            //             ? _selectDate(context)
                                            //             : print('ok');
                                            //       },
                                            //       child: Column(
                                            //         crossAxisAlignment:
                                            //             CrossAxisAlignment
                                            //                 .start,
                                            //         children: <Widget>[
                                            //           Text(
                                            //             "Fecha de nacimiento",
                                            //             style: TextStyle(
                                            //                 color:
                                            //                     Colors.black54,
                                            //                 fontSize: 15),
                                            //           ),
                                            //           SizedBox(
                                            //             height: 2,
                                            //           ),
                                            //           Text(
                                            //             birthdate_string
                                            //                 .toString(),
                                            //             style: TextStyle(
                                            //                 color: primaryGreen,
                                            //                 fontWeight:
                                            //                     FontWeight.w500,
                                            //                 fontSize: 15),
                                            //           )
                                            //         ],
                                            //       )),
                                            // ),
                                            SimpleTextField(
                                                labelText: 'Correo',
                                                initValue:
                                                    jsonVendedor['correo'],
                                                inputType: 'generic',
                                                enabled: editP,
                                                onSaved: (value) =>
                                                    userModel.correo = value,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences),
                                            SimpleTextField(
                                                labelText: 'Teléfono',
                                                initValue:
                                                    jsonVendedor['telefono'],
                                                inputType: 'generic',
                                                enabled: editP,
                                                onSaved: (value) =>
                                                    userModel.telefono = value,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences),
                                            SimpleTextField(
                                                labelText: 'Ubicación',
                                                initValue:
                                                    jsonVendedor['ubicacion'],
                                                inputType: 'generic',
                                                enabled: editP,
                                                onSaved: (value) =>
                                                    userModel.ubicacion = value,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                !editP
                                    ? ButtonPrimary(
                                        mainText: 'Editar',
                                        pressed: () => setState(() {
                                          editP = true;
                                        }),
                                      )
                                    : ButtonPrimary(
                                        mainText: 'Guardar',
                                        pressed: () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            _formKey.currentState.save();
                                            postUser(
                                                jsonVendedor['usuario_id']);
                                          }
                                        },
                                      ),
                                !editP ? Container() : SizedBox(height: 5),
                                !editP
                                    ? Container()
                                    : ButtonLight(
                                        mainText: 'Cancelar',
                                        pressed: () => setState(() {
                                          editP = false;
                                        }),
                                      ),
                                !editP
                                    ?
                                    // Padding(
                                    //     padding:
                                    //         const EdgeInsets.only(top: 20.0),
                                    //     child: InkWell(
                                    //       onTap: () => _showMyDialog(),
                                    //       child: Text('Deshabilitar usuario'),
                                    //     ),
                                    //   )
                                    Padding(
                                        padding: EdgeInsets.only(top: 20.0),
                                        child: MediaQuery.of(context)
                                                    .size
                                                    .width <
                                                600
                                            ? Column(
                                                children: [
                                                  ButtonPrimary(
                                                    mainText:
                                                        'Deshabilitar usuario',
                                                    color: primaryOrange,
                                                    pressed: () =>
                                                        _showMyDialog(false),
                                                  ),
                                                  SizedBox(height: 20),
                                                  InkWell(
                                                    onTap: () =>
                                                        _showMyDialog(true),
                                                    child: Text(
                                                      'Eliminar usuario',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Expanded(
                                                    child: ButtonPrimary(
                                                      mainText:
                                                          'Deshabilitar usuario',
                                                      color: primaryOrange,
                                                      pressed: () =>
                                                          _showMyDialog(false),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () =>
                                                          _showMyDialog(true),
                                                      child: Text(
                                                        'Eliminar usuario',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                      )
                                    : Container()
                              ],
                            ),
                          ],
                        )
                      ],
                    )),
                  ),
          );
  }

  deleteUsr(bool delete) async {
    // 'usuarios?id=${jsonVendedor['usuario_id']}'
    delete
        ? await verdeService
            .deleteService('usuarios?id=${jsonVendedor['usuario_id']}',
                sharedPrefs.clientToken)
            .then((serverResp) {
            var respResponse = jsonDecode(serverResp['response']);

            if (serverResp['status'] == 'server_true') {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(rutaSeleccionada: Client())),
                  (route) => false);

              dialog(true, context, respResponse['message']);
            } else {
              Navigator.pop(context);
              dialog(false, context, respResponse['message']);
            }
          })
        : await verdeService
            .postTokenService(
                null,
                'usuarios/deshabilitar?id=${jsonVendedor['usuario_id']}',
                sharedPrefs.clientToken)
            .then((serverResp) {
            var respResponse = jsonDecode(serverResp['response']);
            if (serverResp['status'] == 'server_true') {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(rutaSeleccionada: Client())),
                  (route) => false);

              dialog(true, context, respResponse['message']);
            } else {
              Navigator.pop(context);
              dialog(false, context, respResponse['message']);
            }
          });
  }

  pickImage() async {
    mediaData = await ImagePickerWeb.getImageInfo;
    print(pickedImage);
  }

  postUser(userID) async {
    VerdeService verdeService = VerdeService();

    var jsonBody = {
      "fecha_nacimiento": userModel.fecha_nacimiento,
      "telefono": userModel.telefono,
      "correo": userModel.correo,
      "primer_apellido": userModel.primer_apellido,
      "segundo_apellido": userModel.segundo_apellido,
      "ubicacion": userModel.ubicacion,
      "nombre": userModel.nombre,
      "imagenes": [
        {
          "nombre_archivo": mediaData == null ? null : mediaData.fileName,
          "img_url": mediaData == null ? null : base64Encode(mediaData.data)
        },
      ]
    };

    // print(jsonBody);

    await verdeService
        .postTokenService(
            jsonBody, 'clientes/perfil?id=$userID', sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      if (serverResp['status'] == 'server_true') {
        setState(() {
          editP = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(rutaSeleccionada: Client())),
            (route) => false);
        dialog(true, context, respResponse['message']).toString();
      } else {
        Navigator.pop(context);
        dialog(false, context, respResponse['message']).toString();
      }
    });
  }

  Future<void> _showMyDialog(bool delete) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              delete ? Text('Eliminar usuario') : Text('Deshabilitar usuario'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                delete
                    ? Text(
                        'Se eliminará a ${jsonVendedor['nombre']} permanentemente.')
                    : Text(
                        'Se deshabilitará a ${jsonVendedor['nombre']}.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: delete ? Text('Eliminar') : Text('Deshabilitar'),
              onPressed: () {
                deleteUsr(delete);
              },
            ),
          ],
        );
      },
    );
  }
}
