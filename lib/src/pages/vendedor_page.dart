import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:jiffy/jiffy.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/model/partner_model.dart';
import 'package:web_verde/src/global.dart';
import 'package:web_verde/src/pages/home_page.dart';
import 'package:web_verde/src/pages/products_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/button_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';

////// Data class
class Partner {
  Partner(
      this.nombre,
      this.primer_apellido,
      this.segundo_apellido,
      this.correo,
      this.telefono,
      this.ubicacion,
      this.url_img,
      this.usuario_id,
      this.created_at,
      this.updated_at,
      this.deleted_at);
  final String nombre;
  final String primer_apellido;
  final String segundo_apellido;
  final String correo;
  final String telefono;
  final String ubicacion;
  final String url_img;
  final String usuario_id;
  final String created_at;
  final String updated_at;
  final String deleted_at;
}

class Vendedor extends StatefulWidget {
  @override
  _VendedorState createState() => _VendedorState();
}

class _VendedorState extends State<Vendedor> with TickerProviderStateMixin {
  var jsonVendedor;
  List<Partner> userData = [];
  List<Partner> searchList = [];

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

    print(sharedPrefs.clientToken.toString());

    getUser().then((value) {
      for (var i = 0; i < jsonVendedor.length; i++) {
        // print(jsonVendedor[i]['nombre'].toString());
        // print('----------------');
        userData.add(Partner(
            jsonVendedor[i]['nombre'].toString(),
            jsonVendedor[i]['primer_apellido'].toString(),
            jsonVendedor[i]['segundo_apellido'].toString(),
            jsonVendedor[i]['correo'].toString(),
            jsonVendedor[i]['telefono'].toString(),
            jsonVendedor[i]['ubicacion'].toString(),
            jsonVendedor[i]['img_url'].toString(),
            jsonVendedor[i]['usuario_id'].toString(),
            jsonVendedor[i]['created_at'].toString(),
            jsonVendedor[i]['updated_at'].toString(),
            jsonVendedor[i]['deleted_at']));
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
            adminModel, 'usuarios?tipo=vendedor', sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'].toString() == 'server_true') {
        var respResponse = jsonDecode(serverResp['response'].toString());
        // print(respResponse[1]);
        setState(() {
          jsonVendedor = respResponse[1];
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
                      'No se encontraron vendedores',
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    )
                  ],
                ),
              )
            : SingleChildScrollView(
                child: PaginatedDataTable(
                // header: const Text('Vendedores'),
                header: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MediaQuery.of(context).size.width < 700
                        ? Container()
                        : Expanded(
                            flex: 1,
                            child: Text(
                              'VENDEDORES',
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
                        onSaved: (value) {},
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
                // availableRowsPerPage: const <int>[10],
                // onRowsPerPageChanged: (int value) {
                //   setState(() {
                //     _rowsPerPage = value;
                //   });
                // },
                columns: kTableColumns,
                source: DessertDataSource(
                    dataVendedor:
                        searchList.length == 0 ? userData : searchList,
                    mycontext: context),

                //   ),
                //  ) ]
              ));
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
                  'Enviar notificación a vendedores',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black87),
                  textAlign: TextAlign.center,
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
                            }),
                      ],
                    )
                  ],
                ),
              ],
            )
          ],
        )),
      ),
    );
  }

  sendNot() async {
    var jsonBody = {
      "titulo": titulo,
      "mensaje": mensaje,
      "tipo_usuario": "vendedor"
    };
    await verdeService
        .postTokenService(jsonBody, 'notificar', sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response'].toString());

      if (serverResp['status'].toString() == 'server_true') {
        Navigator.pop(context);
        dialog(true, context, respResponse['message'].toString());
      } else {
        Navigator.pop(context);
        dialog(false, context, respResponse['message'].toString());
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
  dynamic _vendedorData;
  BuildContext _context;
  DessertDataSource({
    @required List<Partner> dataVendedor,
    BuildContext mycontext,
  })  : _vendedorData = dataVendedor,
        _context = mycontext,
        assert(dataVendedor != null);

  // DessertDataSource({@required User userData}) : _vendedorData = userData;

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);

    if (index >= _vendedorData.length) {
      return null;
    }
    final _user = _vendedorData[index];

    Icon iconStatus;

    if (_vendedorData[index].deleted_at == null) {
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
          _dialogCall(_context, _user);
        },
        cells: <DataCell>[
          DataCell(CircleAvatar(
            backgroundColor: Colors.grey[400],
            backgroundImage: _user.url_img == null
                ? AssetImage('images/isoBlanco.png')
                : NetworkImage(_user.url_img),
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
          // DataCell(
          //   IconButton(
          //       hoverColor: Colors.transparent,
          //       splashColor: Colors.transparent,
          //       icon: const Icon(
          //         Icons.edit,
          //         size: 20,
          //       ),
          //       onPressed: () => ),
        ]);
  }

  Future<void> _dialogCall(BuildContext context, userId) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogInfo(userId: userId);
        });
  }

  @override
  int get rowCount => _vendedorData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class DialogInfo extends StatefulWidget {
  DialogInfo({Key key, @required this.userId}) : super(key: key);

  final dynamic userId;

  @override
  _DialogInfoState createState() => new _DialogInfoState();
}

class _DialogInfoState extends State<DialogInfo> {
  String imagePath;
  Image image;
  Image pickedImage;
  var base64image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String nombreCat;
  var jsonVendedor;

  bool loadInfo = true;

  bool editP = false;

  PartnerModel partnerModel = PartnerModel();

  VerdeService verdeService = VerdeService();

  var mediaData;

  bool userExist = true;

  // public data
  String nombrePub;
  String descPub;
  String telPub;
  String correoPub;

  DateTime birthdate = DateTime.now();
  String birthdate_string =
      Jiffy(DateTime.now()).format("dd-MM-yyy").toString();

  @override
  void initState() {
    super.initState();
    getUser();
    sharedPrefs.init();
  }

  getUser() async {
    sharedPrefs.init();
    // print(sharedPrefs.clientToken);
    await verdeService
        .getService(null, 'vendedor/perfil?id=${widget.userId.usuario_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'].toString() == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        setState(() {
          jsonVendedor = respResponse[1];
          loadInfo = false;

          nombrePub = jsonVendedor['informacion_publica']['nombre'].toString();
          descPub =
              jsonVendedor['informacion_publica']['descripcion'].toString();
          telPub = jsonVendedor['informacion_publica']['telefono'].toString();
          correoPub = jsonVendedor['informacion_publica']['correo'].toString();
          // birthdate =
          //     DateTime.parse(jsonVendedor['fecha_nacimiento'].toString());
          // birthdate_string = Jiffy(jsonVendedor['fecha_nacimiento'].toString())
          //     .format("dd-MM-yyy")
          //     .toString();
          partnerModel.fecha_nacimiento =
              jsonVendedor['fecha_nacimiento'].toString();
        });
      } else {
        setState(() {
          userExist = false;
        });
      }
    });
  }

  habUsr() async {
    await verdeService
        .postTokenService(
            null,
            'usuarios/habilitar?id=${widget.userId.usuario_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response'].toString());

      if (serverResp['status'].toString() == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(rutaSeleccionada: Vendedor())),
            (route) => false);
        dialog(true, context, respResponse['message'].toString());
      } else {
        dialog(false, context, respResponse['message'].toString());
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
  //       partnerModel.fecha_nacimiento =
  //           Jiffy(picked).format("yyy-MM-dd").toString();
  //     });
  // }

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
                        'Detalles del vendedor',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black87),
                        textAlign: TextAlign.center,
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
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Detalles del vendedor',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black87),
                        textAlign: TextAlign.center,
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
                    width: MediaQuery.of(context).size.width / 2,
                    child: SingleChildScrollView(
                        child: new ListBody(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 100,
                                              backgroundColor: Colors.grey[400],
                                              backgroundImage: mediaData != null
                                                  ? MemoryImage(mediaData.data)
                                                  : jsonVendedor['img_url'] ==
                                                          null
                                                      ? AssetImage(
                                                          'images/isoBlanco.png')
                                                      : NetworkImage(
                                                          jsonVendedor[
                                                                  'img_url']
                                                              .toString()),
                                            ),
                                            !editP
                                                ? Container()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5.0),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5.0),
                                                      child: ButtonLight(
                                                          mainText:
                                                              'Seleccionar foto',
                                                          pressed: () async {
                                                            await pickImage();
                                                            setState(() {});
                                                          }),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(),
                                      ),
                                      Expanded(
                                          flex: 4,
                                          child: Column(
                                            children: [
                                              SimpleTextField(
                                                  labelText: 'Nombre',
                                                  initValue:
                                                      jsonVendedor['nombre']
                                                          .toString(),
                                                  inputType: 'nombre',
                                                  enabled: editP,
                                                  onSaved: (value) =>
                                                      partnerModel.nombre =
                                                          value,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences),
                                              SimpleTextField(
                                                  labelText: 'Primer apellido',
                                                  initValue: jsonVendedor[
                                                          'primer_apellido']
                                                      .toString(),
                                                  inputType: 'nombre',
                                                  enabled: editP,
                                                  onSaved: (value) =>
                                                      partnerModel
                                                              .primer_apellido =
                                                          value,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences),
                                              SimpleTextField(
                                                  labelText: 'Segundo apellido',
                                                  initValue: jsonVendedor[
                                                          'segundo_apellido']
                                                      .toString(),
                                                  inputType: 'nombre',
                                                  enabled: editP,
                                                  onSaved: (value) =>
                                                      partnerModel
                                                              .segundo_apellido =
                                                          value,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences),
                                              // Container(
                                              //   width: double.infinity,
                                              //   margin:
                                              //       EdgeInsets.only(top: 15),
                                              //   padding: EdgeInsets.all(5),
                                              //   decoration: BoxDecoration(
                                              //       color: Colors.grey[200],
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               5)),
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
                                              //                 color: Colors
                                              //                     .black54,
                                              //                 fontSize: 15),
                                              //           ),
                                              //           SizedBox(
                                              //             height: 2,
                                              //           ),
                                              //           Text(
                                              //             birthdate_string
                                              //                 .toString(),
                                              //             style: TextStyle(
                                              //                 color:
                                              //                     primaryGreen,
                                              //                 fontWeight:
                                              //                     FontWeight
                                              //                         .w500,
                                              //                 fontSize: 15),
                                              //           )
                                              //         ],
                                              //       )),
                                              // ),
                                              SimpleTextField(
                                                  labelText: 'Correo',
                                                  initValue:
                                                      jsonVendedor['correo']
                                                          .toString(),
                                                  inputType: 'nombre',
                                                  enabled: editP,
                                                  onSaved: (value) =>
                                                      partnerModel.correo =
                                                          value,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences),
                                              SimpleTextField(
                                                  labelText: 'Teléfono',
                                                  initValue:
                                                      jsonVendedor['telefono']
                                                          .toString(),
                                                  inputType: 'nombre',
                                                  enabled: editP,
                                                  onSaved: (value) =>
                                                      partnerModel.telefono =
                                                          value,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences),
                                              SimpleTextField(
                                                  labelText: 'Ubicación',
                                                  initValue:
                                                      jsonVendedor['ubicacion']
                                                          .toString(),
                                                  inputType: 'nombre',
                                                  enabled: editP,
                                                  onSaved: (value) =>
                                                      partnerModel.ubicacion =
                                                          value,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences),
                                            ],
                                          )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  jsonVendedor['informacion_publica']
                                              ['nombre'] ==
                                          null
                                      ? Container()
                                      : Divider(
                                          color: primaryGreen.withOpacity(0.4),
                                          thickness: 2,
                                        ),
                                  jsonVendedor['informacion_publica']
                                              ['nombre'] ==
                                          null
                                      ? Container()
                                      : Text(
                                          'Información pública',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900),
                                        )
                                ],
                              ),
                              jsonVendedor['informacion_publica']['nombre'] ==
                                      null
                                  ? Container()
                                  : Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                flex: 4,
                                                child: Column(
                                                  children: [
                                                    SimpleTextField(
                                                        initValue: nombrePub
                                                            .toString(),
                                                        inputType: 'generic',
                                                        enabled: editP,
                                                        onSaved: (value) =>
                                                            nombrePub = value,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences),
                                                    SimpleTextField(
                                                        initValue: correoPub
                                                            .toString(),
                                                        inputType: 'generic',
                                                        enabled: editP,
                                                        onSaved: (value) =>
                                                            correoPub = value,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences),
                                                    SimpleTextField(
                                                        initValue:
                                                            telPub.toString(),
                                                        inputType: 'generic',
                                                        enabled: editP,
                                                        onSaved: (value) =>
                                                            telPub = value,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences),
                                                  ],
                                                )),
                                            Expanded(
                                              flex: 1,
                                              child: Container(),
                                            ),
                                            Expanded(
                                                flex: 4,
                                                child: Column(
                                                  children: [
                                                    SimpleTextField(
                                                        initValue:
                                                            descPub.toString(),
                                                        inputType: 'generic',
                                                        enabled: editP,
                                                        onSaved: (value) =>
                                                            descPub = value,
                                                        maxLines: 5,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences),
                                                  ],
                                                )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ButtonLight(
                                                mainText: 'Ver Productos',
                                                pressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProductsPage(
                                                              infoVendedor:
                                                                  jsonVendedor,
                                                            ))),
                                              ),
                                            ),
                                          ],
                                        )
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
                                        if (_formKey.currentState.validate()) {
                                          _formKey.currentState.save();
                                          postUser(jsonVendedor['usuario_id']
                                              .toString());
                                        }
                                      },
                                    ),
                              !editP
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ButtonPrimary(
                                              mainText: 'Deshabilitar usuario',
                                              color: primaryOrange,
                                              pressed: () =>
                                                  _showMyDialog(false),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => _showMyDialog(true),
                                              child: Text(
                                                'Eliminar usuario',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ],
                    )),
                  ));
  }

  deleteVend(bool delete) async {
    delete
        ? await verdeService
            .deleteService(
                'usuarios?id=${jsonVendedor['usuario_id'].toString()}',
                sharedPrefs.clientToken)
            .then((serverResp) {
            var respResponse = jsonDecode(serverResp['response'].toString());
            // dialog(false, context, respResponse['message'].toString());
            if (serverResp['status'].toString() == 'server_true') {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(rutaSeleccionada: Vendedor())),
                  (route) => false);

              dialog(true, context, respResponse['message'].toString());
            } else {
              Navigator.pop(context);
              dialog(false, context, respResponse['message'].toString());
            }
          })
        : await verdeService
            .postTokenService(
                null,
                'usuarios/deshabilitar?id=${jsonVendedor['usuario_id'].toString()}',
                sharedPrefs.clientToken)
            .then((serverResp) {
            var respResponse = jsonDecode(serverResp['response'].toString());
            if (serverResp['status'].toString() == 'server_true') {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(rutaSeleccionada: Vendedor())),
                  (route) => false);
              dialog(true, context, respResponse['message'].toString());
            } else {
              dialog(false, context, respResponse['message'].toString());
            }
          });
  }

  pickImage() async {
    mediaData = await ImagePickerWeb.getImageInfo;
    // print(pickedImage);
  }

  postUser(userID) async {
    VerdeService verdeService = VerdeService();

    var jsonBody = {
      "fecha_nacimiento": partnerModel.fecha_nacimiento,
      "telefono": partnerModel.telefono,
      "correo": partnerModel.correo,
      "primer_apellido": partnerModel.primer_apellido,
      "segundo_apellido": partnerModel.segundo_apellido,
      "ubicacion": partnerModel.ubicacion,
      "nombre": partnerModel.nombre,
      "imagenes": [
        {
          "nombre_archivo": mediaData == null ? null : mediaData.fileName,
          "img_url": mediaData == null ? null : base64Encode(mediaData.data)
        },
      ]
    };

    var bodyPublic = {
      "nombre": nombrePub,
      "descripcion": descPub,
      "telefono": telPub,
      "correo": correoPub
    };

    // print(jsonBody);

    await verdeService
        .postTokenService(
            jsonBody, 'vendedor/perfil?id=$userID', sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response'].toString());
// dialog(true, context, respResponse['message'].toString()).toString();
      if (serverResp['status'].toString() == 'server_true') {
        verdeService
            .postTokenService(bodyPublic, 'vendedor/publico?id=$userID',
                sharedPrefs.clientToken)
            .then((serverResp) => {
                  if (serverResp['status'].toString() == 'server_true')
                    {
                      setState(() {
                        editP = false;
                      }),
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomePage(rutaSeleccionada: Vendedor())),
                          (route) => false),
                      dialog(true, context, respResponse['message'].toString())
                          .toString(),
                    }
                  else
                    {
                      dialog(false, context, respResponse['message'].toString())
                          .toString(),
                    }
                });
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
                        'Se eliminará a ${jsonVendedor['nombre'].toString()} y sus productos permanentemente.')
                    : Text(
                        'Se deshabilitará a ${jsonVendedor['nombre'].toString()} y sus producto.'),
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
                deleteVend(delete);
              },
            ),
          ],
        );
      },
    );
  }
}
