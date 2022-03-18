import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/global.dart';
import 'package:web_verde/src/pages/create_announcement.dart';
import 'package:web_verde/src/pages/home_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/button_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';
import 'package:date_time_picker/date_time_picker.dart';

class AnunciosModel {
  AnunciosModel(
    this.active,
    this.producto_id,
    this.imagen,
    this.anuncio_id,
    this.fechas,
    this.nombre_vendedor,
    this.nombre_producto,
  );
  final String active;
  final String producto_id;
  final String imagen;
  final String anuncio_id;
  final String fechas;
  final String nombre_vendedor;
  final String nombre_producto;
}

class AnnouncementsPage extends StatefulWidget {
  AnnouncementsPage({Key key}) : super(key: key);

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage>
    with TickerProviderStateMixin {
  bool loadinfo = true;
  AnimationController animationController;

  List<AnunciosModel> anuncios = [];

  var jsonAnuncios;

  bool _isSearching;
  List<AnunciosModel> searchList = [];

//Variables de modelos
  VerdeService verdeService = VerdeService();
  AdminModel adminModel = AdminModel();

  @override
  void initState() {
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
    print(sharedPrefs.clientToken.toString());
    getAnuncios();
    super.initState();
  }

//Funcion para obtener anuncios
  getAnuncios() async {
    await verdeService
        .getService('adminModel', "enlistar/anuncios", sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var respAnuncios = jsonDecode(serverResp['response']);
        //anuncios = respAnuncios[1];
        print(respAnuncios[1][0]);
        //print(respAnuncios[1][1]);

        setState(() {
          loadinfo = false;
          jsonAnuncios = respAnuncios[1];
          for (var i = 0; i < jsonAnuncios.length; i++) {
            anuncios.add(AnunciosModel(
              jsonAnuncios[i]['active'].toString(),
              jsonAnuncios[i]['producto_id'].toString(),
              jsonAnuncios[i]['imagen'].toString(),
              jsonAnuncios[i]['anuncio_id'].toString(),
              jsonAnuncios[i]['fechas'].toString(),
              jsonAnuncios[i]['nombre_vendedor'].toString(),
              jsonAnuncios[i]['nombre_producto'].toString(),
            ));
          }
          print('anuncios');
          //print(anuncios[1]);
        });
      }
    });
  }

  void searchOperation(String searchText) {
    searchList.clear();
    _handleSearchStart();
    if (_isSearching != null) {
      for (int i = 0; i < anuncios.length; i++) {
        String data = anuncios[i].nombre_producto;
        if (data.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            searchList.add(anuncios[i]);
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
  Widget build(BuildContext context) {
    int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
    return /* loadinfo
        ? Center(
            child: CircularProgressIndicator(
                //backgroundColor: primaryGreen,
                //valueColor: animationController
                //    .drive(ColorTween(begin: primaryOrange, end: primaryYellow)),
                ),
          )
        : anuncios.length == 0
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
                      'No se encontraron anuncios',
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    )
                  ],
                ),
              )
            :  */
        ListView(children: [
      SingleChildScrollView(
        //child: Text('aquí va la tabla'),
        child: PaginatedDataTable(
          header: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MediaQuery.of(context).size.width < 700
                  ? Container()
                  : Expanded(
                      flex: 1,
                      child: Text(
                        'ANUNCIOS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: primaryGreen,
                            fontSize: 25),
                      ),
                    ),
              Container(
                  child: Tooltip(
                message: 'Agregar nuevo anuncio',
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(50)),
                  child: IconButton(
                      onPressed: () {
//                                  MaterialPageRoute(
//                                      builder: (context) =>
//                                          CreateAnnouncement());

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateAnnouncement()));
                      },
                      icon: Icon(Icons.add, color: Colors.white)),
                ),
              )),
              SizedBox(
                width: 30,
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
          columns: kTableColumns,
          source: AnunciosDataSourceTable(
            dataAnuncios: searchList.length == 0 ? anuncios : searchList,
            mycontext: context,
          ),
        ),
      ),
    ]);
  }
}

////// Columns in table.
const kTableColumns = <DataColumn>[
  DataColumn(
    label: Text(
      'Estatus',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Nombre del Producto',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Nombre del Vendedor/tienda',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Información general',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Eliminar',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
];

class AnunciosDataSourceTable extends DataTableSource {
  BuildContext _context;
  dynamic _anunciosData;
  AnunciosDataSourceTable({@required List dataAnuncios, BuildContext mycontext})
      : _anunciosData = dataAnuncios,
        _context = mycontext,
        assert(dataAnuncios != null);

  int _selectedCount = 0;

  postEliminarAnuncio(idAnuncio) async {
    VerdeService verdeService = VerdeService();

    var jsonBody = {
      "anuncio_id": idAnuncio,
    };
    await verdeService
        .postTokenService(jsonBody, 'eliminar/anuncio', sharedPrefs.clientToken)
        .then((serverResp) {
      print(jsonBody);
      var respResponse = jsonDecode(serverResp['response']);
      // dialog(false, context, respResponse['message'].toString());
      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            _context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: AnnouncementsPage())),
            (route) => false);
        dialog(true, _context, respResponse['message'].toString());
      } else {
        dialog(false, _context, respResponse['message'].toString());
      }
    });
  }

  @override
  DataRow getRow(int index) {
    // TODO: implement getRow
    assert(index >= 0);

    if (index >= _anunciosData.length) {
      return null;
    }
    final _anuncio = _anunciosData[index];
    Icon iconStatus;

    if (_anuncio.active == 'true') {
      iconStatus = Icon(
        Icons.check,
        color: primaryGreen,
      );
    } else {
      iconStatus = Icon(Icons.close, color: primaryOrange);
    }

    return DataRow.byIndex(index: index,
        //onSelectChanged: (bool value) {
        //  _dialogCall(_context, _anuncio.productos_id);
        //},
        cells: <DataCell>[
          DataCell(
            IconButton(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: iconStatus,
                onPressed: () {}),
          ),
          DataCell(Text('${_anuncio.nombre_producto}')),
          DataCell(Text('${_anuncio.nombre_vendedor}')),
          DataCell(Container(
            color: Color(0xFF70BB68),
            width: 92,
            height: 32,
            child: TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ))),
                onPressed: () {
                  _detallesDialogCall(_context, _anuncio.anuncio_id, _anuncio);
                },
                child: Center(
                  child: Container(
                    child: Text('Detalles',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                )),
          )),

          DataCell(Container(
            color: Colors.red,
            width: 92,
            height: 32,
            child: TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ))),
                onPressed: () {
                  // _dialogCall(_context, _anuncio.anuncio_id);
                  postEliminarAnuncio(_anuncio.anuncio_id);
                },
                child: Center(
                  child: Container(
                    child: Text('Eliminar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                )),
          )),

          //DataCell(Text('$_anuncio.')),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _anunciosData.length;
  @override
  int get selectedRowCount => 0;
}

Future _dialogCall(BuildContext context, idAnuncio) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        print(idAnuncio);
        return Text('Hola'); //MyDialog();
      });
}

Future _detallesDialogCall(BuildContext context, idAnuncio, infoAnuncio) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        print(idAnuncio);
        return DetallesDialog(
            idAnuncio: idAnuncio, infoAnuncio: infoAnuncio); //MyDialog();
      });
}

class DetallesDialog extends StatefulWidget {
  DetallesDialog(
      {Key key, @required this.idAnuncio, @required this.infoAnuncio})
      : super(key: key);
  final String idAnuncio;
  final dynamic infoAnuncio;

  @override
  State<DetallesDialog> createState() => _DetallesDialogState();
}

class _DetallesDialogState extends State<DetallesDialog> {
  VerdeService verdeService = VerdeService();
  var anunciosDetalles;
  bool editP = false;

  bool loadInfo;
  String nombreAnuncio;
  var mediaData;
  String imagePath;
  Image image;
  Image pickedImage;
  var base64image;
  var imagesBody;
  bool imagenCargada;

  //Fechas
  bool fechasAgregadas = false;
  List<String> listaFechas = [];
  List<Widget> addFechas = [];
  int cantidadFechasEditables;
  bool activarDatePicker;
  bool activarDatePicker2;

  @override
  void initState() {
    imagenCargada = false;
    activarDatePicker = false;
    loadInfo = false;
    getAnuncioDetalles();
    super.initState();
  }

  getAnuncioDetalles() async {
    sharedPrefs.init();
    await verdeService.postTokenService({"anuncio_id": widget.idAnuncio},
        'detalles/anuncio', sharedPrefs.clientToken).then((serverResp) {
      print(serverResp);
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        print(respResponse[1]);
        setState(() {
          loadInfo = true;
          anunciosDetalles = respResponse[1][0];
          cantidadFechasEditables = anunciosDetalles['fechasActivas'].length;
          print(anunciosDetalles);
          print(cantidadFechasEditables);
        });
      }
    });
  }

  pickImage() async {
    mediaData = await ImagePickerWeb.getImageInfo;
    // print(pickedImage);
  }

  void _addDatedWidget() {
    setState(() {
      addFechas.add(_datePickerForm());
      cantidadFechasEditables--;
    });
  }

  void _removeDatedWidget() {
    setState(() {
      addFechas.removeLast();
      listaFechas.removeLast();
      cantidadFechasEditables++;
    });
  }

  Widget _datePickerForm() {
    return Container(
      child: DateTimePicker(
        initialValue: '',
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        dateLabelText: 'Fecha',
        onChanged: (val) {
          setState(() {
            fechasAgregadas = true;
            print(val);
            listaFechas.add(val);
            print(listaFechas);
          });
        },
        validator: (val) {
          print(val);
          return null;
        },
        onSaved: (val) {
          print(val);
          print(val.runtimeType);
        },
      ),
    );
  }

//  Future<void> getImages64Array() async {
//    Uint8List byteData = await File(mediaData).readAsBytes();
//    setState(() {
//      imagesBody.add({
//        "nombre_archivo": mediaData,
//        "img_url": base64Encode(byteData.buffer.asUint8List())
//      });
//    });
//  }
//
  postEditAnuncio(idAnuncio) async {
    VerdeService verdeService = VerdeService();

    var jsonBody = {
      "anuncio_id": idAnuncio,
      "imagenes": [
        {
          "nombre_archivo": mediaData == null ? null : mediaData.fileName,
          "img_url": mediaData == null ? null : base64Encode(mediaData.data)
        }
      ],
      "fechas": (fechasAgregadas == false)
          ? anunciosDetalles['fechasActivas']
          : listaFechas,
    };

    print(jsonBody['imagen']);
    print(jsonBody['anuncio_id']);
    print(jsonBody['fechas']);

    await verdeService
        .postTokenService(jsonBody, 'editar/anuncio', sharedPrefs.clientToken)
        .then((serverResp) {
      print(jsonBody);
      var respResponse = jsonDecode(serverResp['response']);
      // dialog(false, context, respResponse['message'].toString());
      if (serverResp['status'] == 'server_true') {
        setState(() {
          editP = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: AnnouncementsPage())),
            (route) => false);
        dialog(true, context, respResponse['message'].toString());
      } else {
        dialog(false, context, respResponse['message'].toString());
      }
    });
  }

  postEliminarAnuncio(idAnuncio) async {
    print(idAnuncio);
    var jsonBody = {
      "anuncio_id": idAnuncio,
    };
    await verdeService
        .postTokenService(jsonBody, 'editar/anuncio', sharedPrefs.clientToken)
        .then((serverResp) {
      print(jsonBody);
      var respResponse = jsonDecode(serverResp['response']);
      // dialog(false, context, respResponse['message'].toString());
      if (serverResp['status'] == 'server_true') {
        setState(() {
          editP = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: AnnouncementsPage())),
            (route) => false);
        dialog(true, context, respResponse['message'].toString());
      } else {
        dialog(false, context, respResponse['message'].toString());
      }
    });
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
                    widget.infoAnuncio.anuncio_id,
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
        content: loadInfo == false
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
                        Form(
                          //key: _formKey,
                          child: SimpleTextField(
                              labelText: 'Nombre del vendedor/tienda',
                              initValue: widget.infoAnuncio.nombre_vendedor,
                              inputType: 'generic',
                              enabled: false,
                              onSaved: (value) =>
                                  {}, //(value) => nombrecat = value,
                              textCapitalization: TextCapitalization.sentences),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: Form(
                            //key: _formKey,
                            child: SimpleTextField(
                                labelText: 'Nombre del producto',
                                initValue: anunciosDetalles['nombre'],
                                inputType: 'generic',
                                enabled: editP,
                                onSaved: (value) =>
                                    {}, //(value) => nombrecat = value,
                                textCapitalization:
                                    TextCapitalization.sentences),
                          ),
                        ),
                        Container(
                            child: Form(
                          //key: _formKey,
                          child: SimpleTextField(
                              labelText: 'Fechas activas',
                              initValue: anunciosDetalles['fechasActivas'] ==
                                      null
                                  ? 'No tienes fechas activas'
                                  : anunciosDetalles['fechasActivas']
                                      .join(' / ')
                                      .toString(), //widget.categoryInfo.nombre,
                              inputType: 'generic',
                              enabled: editP,
                              onSaved: (value) => {
                                    listaFechas.add(value)
                                  }, //(value) => nombrecat = value,
                              textCapitalization: TextCapitalization.sentences),
                        )),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                            child: Form(
                          //key: _formKey,
                          child: SimpleTextField(
                              mainColor: Colors.grey[200],
                              labelText: 'Fechas Inactiva',
                              initValue: anunciosDetalles['fechasInactivas'] ==
                                      null
                                  ? 'No tienes fechas activas'
                                  : anunciosDetalles['fechasInactivas']
                                      .join(' / ')
                                      .toString(), //widget.categoryInfo.nombre,
                              inputType: 'generic',
                              enabled: editP,
                              onSaved: (value) => {
                                    listaFechas.add(value)
                                  }, //(value) => nombrecat = value,
                              textCapitalization: TextCapitalization.sentences),
                        )),
                        SizedBox(
                          height: 30,
                        ),
                        !editP
                            ? Container()
                            : Column(
                                children: [
                                  Container(
                                      child: Text(
                                          'Nuevas fechas ($cantidadFechasEditables).')),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: addFechas.length,
                                      itemBuilder: (context, index) {
                                        return addFechas[index];
                                      }),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      color: Color(0xFF70BB68),
                                      width: 506,
                                      height: 48,
                                      child: TextButton(
                                        style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                        ))),
                                        onPressed: () {
                                          _addDatedWidget();
                                        },
                                        child: Center(
                                            child: Container(
                                          child: Icon(Icons.add,
                                              color: Colors.white),
                                        )),
                                      )),
                                  SizedBox(height: 10),
                                  ////////////////
                                  (addFechas.length > 1)
                                      ? Container(
                                          color: Colors.red,
                                          width: 506,
                                          height: 48,
                                          child: TextButton(
                                            style: ButtonStyle(
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ))),
                                            onPressed: () {
                                              _removeDatedWidget();
                                            },
                                            child: Center(
                                                child: Container(
                                              child: Icon(Icons.remove,
                                                  color: Colors.white),
                                            )),
                                          ))
                                      : Container(),
                                ],
                              ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          width: 310.00,
                          height: 152.00,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: NetworkImage(anunciosDetalles['imagen']),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          child: Container(
                              decoration: new BoxDecoration(
                                  image: new DecorationImage(
                            image: mediaData != null
                                ? MemoryImage(mediaData.data)
                                : NetworkImage(widget.infoAnuncio.imagen),
                            fit: BoxFit.fitHeight,
                          ))),
                        ),
                        SizedBox(height: 20),
                        !editP
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: ButtonLight(
                                      mainText: 'Seleccionar foto',
                                      pressed: () async {
                                        await pickImage();
                                        setState(() {
                                          imagenCargada = true;
                                        });
                                      }),
                                ),
                              ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: editP == false
                                  ? (anunciosDetalles['fechasActivas'].length >
                                          1)
                                      ? ButtonPrimary(
                                          mainText: 'Editar',
                                          pressed: () {
                                            print(editP);
                                            setState(() {
                                              editP = true;
                                            });
                                          },
                                        )
                                      : Container()
                                  : ButtonPrimary(
                                      mainText: 'Guardar',
                                      pressed: () {
                                        if (imagenCargada = true) {
                                          postEditAnuncio(
                                              widget.infoAnuncio.anuncio_id);
                                        }
                                        if (listaFechas.length >
                                            cantidadFechasEditables) {
                                          postEditAnuncio(
                                              widget.infoAnuncio.anuncio_id);
                                        }

                                        if (listaFechas.length >
                                            cantidadFechasEditables) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  elevation: 10,
                                                  title: Text('Aviso'),
                                                  content: Text(
                                                      'El numero de nuevas fechas es mayor que las fechas disponibles ¿Quieres continuar?'),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Close'),
                                                    ),
                                                    FlatButton(
                                                      onPressed: () {
                                                        print('mayor');

                                                        postEditAnuncio(widget
                                                            .infoAnuncio
                                                            .anuncio_id);
                                                      },
                                                      child: Text('Continuar'),
                                                    )
                                                  ],
                                                );
                                              });
                                        }

                                        if (listaFechas.length <
                                                cantidadFechasEditables &&
                                            fechasAgregadas == true) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  elevation: 10,
                                                  title: Text('Aviso'),
                                                  content: Text(
                                                      'El numero de nuevas fechas es menor que las fechas disponibles ¿Quieres continuar?'),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Close'),
                                                    ),
                                                    FlatButton(
                                                      onPressed: () {
                                                        print('mayor');

                                                        postEditAnuncio(widget
                                                            .infoAnuncio
                                                            .anuncio_id);
                                                      },
                                                      child: Text('Continuar'),
                                                    )
                                                  ],
                                                );
                                              });
                                        }
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                )),
              ));
  }
}
//}
