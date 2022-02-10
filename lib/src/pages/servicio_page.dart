import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/pages/home_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/button_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';

import '../global.dart';

////// Data class
class Servicio {
  Servicio(
      this.nombre,
      this.descripcion,
      this.nombre_contacto,
      this.ubicacion,
      this.telefono,
      this.correo,
      this.imagenes,
      this.status,
      this.created_at,
      this.updated_at,
      this.servicio_id);
  final String nombre;
  final String descripcion;
  final String nombre_contacto;
  final String ubicacion;
  final String telefono;
  final String correo;
  final dynamic imagenes;
  final String status;
  final String created_at;
  final String updated_at;
  final String servicio_id;
}

class ServicePage extends StatefulWidget {
  @override
  _ServiceState createState() => _ServiceState();
}

class _ServiceState extends State<ServicePage> with TickerProviderStateMixin {
  var jsonService;
  List<Servicio> serviceData = [];
  List<Servicio> searchList = [];

  VerdeService verdeService = VerdeService();
  AdminModel adminModel = AdminModel();
  AnimationController animationController;

  bool loadServices = true;

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

    getServicio().then((value) {
      for (var i = 0; i < jsonService.length; i++) {
        serviceData.add(Servicio(
          jsonService[i]['nombre'],
          jsonService[i]['descripcion'],
          jsonService[i]['nombre_contacto'],
          jsonService[i]['ubicacion'],
          jsonService[i]['telefono_contacto'],
          jsonService[i]['email_contacto'],
          jsonService[i]['imagenes'],
          jsonService[i]['status'],
          jsonService[i]['created_at'],
          jsonService[i]['updated_at'],
          jsonService[i]['servicio_id'],
        ));
      }
      setState(() {
        loadServices = false;
      });
    });

    super.initState();
  }

  getServicio() async {
    sharedPrefs.init();
    print(sharedPrefs.clientToken);
    await verdeService
        .getService(adminModel, 'servicios', sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        setState(() {
          jsonService = respResponse[1];
        });
      }
    });
  }

  void searchOperation(String searchText) {
    searchList.clear();
    _handleSearchStart();
    if (_isSearching != null) {
      for (int i = 0; i < userData.length; i++) {
        String dataNombre = serviceData[i].nombre;
        String dataCNombre = serviceData[i].nombre_contacto;
        if (dataNombre.toLowerCase().contains(searchText.toLowerCase()) ||
            dataCNombre.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            searchList.add(serviceData[i]);
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
    return loadServices
        ? Center(
            child: CircularProgressIndicator(
              backgroundColor: primaryGreen,
              valueColor: animationController
                  .drive(ColorTween(begin: primaryOrange, end: primaryYellow)),
            ),
          )
        : serviceData.length == 0
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
                      'No se encontraron servicios',
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    )
                  ],
                ),
              )
            : SingleChildScrollView(
                child: PaginatedDataTable(
                // header: const Text('Servicios'),
                header: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MediaQuery.of(context).size.width < 700
                        ? Container()
                        : Expanded(
                            flex: 1,
                            child: Text(
                              'SERVICIOS',
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
                showCheckboxColumn: false,
                // rowsPerPage: _rowsPerPage,
                availableRowsPerPage: const <int>[10],
                columns: kTableColumns,
                source: DessertDataSource(
                    mycontext: context,
                    dataServicio:
                        searchList.length == 0 ? serviceData : searchList),

                //   ),
                //  ) ]
              ));
  }
}

////// Columns in table.
const kTableColumns = <DataColumn>[
  DataColumn(
      label: Text(
    'Status',
    style: TextStyle(fontWeight: FontWeight.w700),
  )),
  DataColumn(
    label: Text(
      'Nombre',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
      label: Text(
    'Descripción',
    style: TextStyle(fontWeight: FontWeight.w700),
  )
      // tooltip: 'The total amount of food energy in the given serving size.',
      // numeric: true,
      ),
  DataColumn(
      label: Text(
    'Nombre de contacto',
    style: TextStyle(fontWeight: FontWeight.w900),
  )),
  DataColumn(
      label: Text(
    'Telefono',
    style: TextStyle(fontWeight: FontWeight.w700),
  )),
  DataColumn(
      label: Text(
    'Correo',
    style: TextStyle(fontWeight: FontWeight.w700),
  )),
  DataColumn(
      label: Text(
    'Fecha de registro',
    style: TextStyle(fontWeight: FontWeight.w700),
  )),
];

////// Data source class for obtaining row data for PaginatedDataTable.
class DessertDataSource extends DataTableSource {
  BuildContext _context;
  dynamic _serviceData;
  DessertDataSource({
    @required List<Servicio> dataServicio,
    BuildContext mycontext,
  })  : _serviceData = dataServicio,
        _context = mycontext,
        assert(dataServicio != null);

  // DessertDataSource({@required User serviceData}) : _serviceData = serviceData;

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);

    if (index >= _serviceData.length) {
      return null;
    }
    final _user = _serviceData[index];

    Icon iconStatus;

    if (_serviceData[index].status == 'aceptado') {
      iconStatus = Icon(
        Icons.check,
        color: primaryGreen,
      );
    } else if (_serviceData[index].status == 'pendiente') {
      iconStatus = Icon(Icons.remove, color: Colors.blue[300]);
    } else if (_serviceData[index].status == 'rechazado') {
      iconStatus = Icon(
        Icons.close,
        color: primaryOrange,
      );
    } else {
      iconStatus = Icon(Icons.remove, color: Colors.blue[300]);
    }

    return DataRow.byIndex(
        index: index, // DONT MISS THIS
        onSelectChanged: (bool value) {
          _dialogCall(_context, _user);
        },
        cells: <DataCell>[
          DataCell(
            IconButton(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: iconStatus,
                onPressed: (){}),
          ),
          DataCell(Text('${_user.nombre}')),
          DataCell(Container(
              width: 150,
              child: Text(
                '${_user.descripcion}',
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ))),
          DataCell(Text('${_user.nombre_contacto}')),
          DataCell(Text('${_user.telefono}')),
          DataCell(Text('${_user.correo}')),
          DataCell(Text('${_user.created_at}')),
        ]);
  }

  Future<void> _dialogCall(BuildContext context, serviceInfo) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogInfo(serviceInfo: serviceInfo);
        });
  }

  @override
  int get rowCount => _serviceData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class DialogInfo extends StatefulWidget {
  DialogInfo({Key key, @required this.serviceInfo}) : super(key: key);

  final dynamic serviceInfo;

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
  var jsonCat;

  bool loadInfo = true;

  VerdeService verdeService = VerdeService();

  Icon iconStatus;

  String estado;

  Widget accionesStatus;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.serviceInfo.imagenes.length; i++) {
      imagesProd.add(widget.serviceInfo.imagenes[i]['img_url']);
    }

    if (widget.serviceInfo.status == 'aceptado') {
      estado = 'ACEPTADO';
      iconStatus = Icon(
        Icons.check,
        color: primaryGreen,
      );
      accionesStatus = ButtonPrimary(
        mainText: 'Rechazar servicio',
        color: primaryOrange,
        pressed: () => rechazarServicio(),
      );
    } else if (widget.serviceInfo.status == 'pendiente') {
      estado = 'PENDIENTE';
      iconStatus = Icon(Icons.remove, color: Colors.blue[300]);
      accionesStatus = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonPrimary(
            mainText: 'Rechazar',
            color: primaryOrange,
            pressed: () => rechazarServicio(),
          ),
          ButtonPrimary(
            mainText: 'Aceptar',
            pressed: () => aceptarServicio(),
          )
        ],
      );
    } else if (widget.serviceInfo.status == 'rechazado') {
      estado = 'RECHAZADO';
      iconStatus = Icon(
        Icons.close,
        color: primaryOrange,
      );
      accionesStatus = ButtonPrimary(
          mainText: 'Aceptar servicio', pressed: () => aceptarServicio());
    } else {
      estado = 'PENDIENTE';
      iconStatus = Icon(Icons.remove, color: Colors.blue[300]);
      accionesStatus = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonPrimary(
            mainText: 'Rechazar',
            color: primaryOrange,
            pressed: () => rechazarServicio(),
          ),
          ButtonPrimary(
            mainText: 'Aceptar',
            pressed: () => aceptarServicio(),
          )
        ],
      );
    }
    sharedPrefs.init();
  }

  aceptarServicio() async {
    await verdeService
        .postTokenService(
            null,
            'servicios/aceptar?id=${widget.serviceInfo.servicio_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      dialog(true, context, respResponse['message']);
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: ServicePage())),
            (route) => false);
        dialog(true, context, respResponse['message']);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: ServicePage())),
            (route) => false);
        dialog(false, context, respResponse['message']);
      }
    });
  }

  rechazarServicio() async {
    await verdeService
        .postTokenService(
            null,
            'servicios/rechazar?id=${widget.serviceInfo.servicio_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: ServicePage())),
            (route) => false);
        dialog(true, context, respResponse['message']);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: ServicePage())),
            (route) => false);
        dialog(false, context, respResponse['message']);
      }
    });
  }

  deleteServicio() async {
    await verdeService
        .deleteService('servicios?id=${widget.serviceInfo.servicio_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      // dialog(false, context, respResponse['message']);
      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: ServicePage())),
            (route) => false);
        dialog(true, context, respResponse['message']);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: ServicePage())),
            (route) => false);
        dialog(false, context, respResponse['message']);
      }
    });
  }

  List<dynamic> imagesProd = List<dynamic>();

  Widget mybuildGridView() {
    return GridView.count(
      crossAxisCount: 1,
      scrollDirection: Axis.horizontal,
      shrinkWrap: false,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      mainAxisSpacing: 5.0,
      padding: EdgeInsets.all(0),
      children: List.generate(imagesProd.length, (index) {
        return Container(
          width: 200,
          height: 200,
          child: Image(
            image: NetworkImage(imagesProd[index]),
            fit: BoxFit.cover,
          ),
          // );
        );
      }),
    );
  }

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
                    'Detalles del servicio',
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
          width: MediaQuery.of(context).size.width / 2,
          child: SingleChildScrollView(
              child: new ListBody(
            children: <Widget>[
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'STATUS: ',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      iconStatus,
                      Flexible(
                          child: Text(
                        estado,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                  SimpleTextField(
                      labelText: 'Nombre',
                      initValue: widget.serviceInfo.nombre,
                      inputType: 'generic',
                      enabled: false,
                      onSaved: null,
                      textCapitalization: TextCapitalization.sentences),
                  SimpleTextField(
                      labelText: 'Descripción',
                      initValue: widget.serviceInfo.descripcion,
                      inputType: 'generic',
                      enabled: false,
                      onSaved: null,
                      textCapitalization: TextCapitalization.sentences),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text('Información de contacto'),
                  SimpleTextField(
                      labelText: 'Nombre de contacto',
                      initValue: widget.serviceInfo.nombre_contacto,
                      inputType: 'generic',
                      enabled: false,
                      onSaved: null,
                      textCapitalization: TextCapitalization.sentences),
                  SimpleTextField(
                      labelText: 'Ubicación',
                      initValue: widget.serviceInfo.ubicacion,
                      inputType: 'generic',
                      enabled: false,
                      onSaved: null,
                      textCapitalization: TextCapitalization.sentences),
                  SimpleTextField(
                      labelText: 'Teléfono',
                      initValue: widget.serviceInfo.telefono,
                      inputType: 'generic',
                      enabled: false,
                      onSaved: null,
                      textCapitalization: TextCapitalization.sentences),
                  SimpleTextField(
                      labelText: 'Correo',
                      initValue: widget.serviceInfo.correo,
                      inputType: 'generic',
                      enabled: false,
                      onSaved: null,
                      textCapitalization: TextCapitalization.sentences),
                  SizedBox(height: 20),
                  widget.serviceInfo.imagenes.length == 0
                      ? Container()
                      : ButtonLight(
                          mainText: 'Ver imágenes',
                          pressed: () => _showMyDialog(
                              widget.serviceInfo.nombre,
                              widget.serviceInfo.imagenes),
                        ),
                  SizedBox(height: 20),
                  accionesStatus,
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () => deleteServicio(),
                    child: Text('Eliminar servicio'),
                  )
                ],
              )
            ],
          )),
        ));
  }

  Future<void> _showMyDialog(String serviceName, dynamic images) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    serviceName,
                    style: TextStyle(color: Colors.black87),
                    textAlign: TextAlign.center,
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
            width: MediaQuery.of(context).size.width / 2,
            child: Column(children: <Widget>[
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: images.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        child: Image(
                          image: NetworkImage(images[index]['img_url']),
                          fit: BoxFit.contain,
                          height: 200,
                        ),
                      ),
                    );
                  },
                ),
              )
            ]),
          ),
        );
      },
    );
  }
}
