import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/pages/subcat_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/button_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';

import '../global.dart';
import 'home_page.dart';

////// Data class.s
class Cat {
  Cat(this.nombre, this.categoria_id, this.img_url, this.estado,
      this.created_at, this.updated_at);
  final String nombre;
  final String categoria_id;
  final String img_url;
  final String estado;
  final String created_at;
  final String updated_at;
}

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with TickerProviderStateMixin {
  var jsonVendedor;
  List<Cat> userData = [];
  List<Cat> searchList = [];

  var category = [];

  VerdeService verdeService = VerdeService();
  AdminModel adminModel = AdminModel();
  bool loadInfo = true;
  AnimationController animationController;

  Image pickedImage;

  bool loadimage = true;

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

    getCategory().then((value) {
      for (var i = 0; i < category.length; i++) {
        userData.add(Cat(
            category[i]['nombre'],
            category[i]['categoria_id'],
            category[i]['img_url'],
            category[i]['estado'],
            category[i]['created_at'],
            category[i]['updated_at']));
      }
      setState(() {
        loadInfo = false;
      });
    });

    super.initState();
  }

  getCategory() async {
    await verdeService
        .getService(adminModel, 'categorias', sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var jsonCat = jsonDecode(serverResp['response']);

        setState(() {
          for (int i = 0; i <= jsonCat[1].length - 1; i++) {
            if (jsonCat[1][i]['categoria_padre_id'] == null) {
              category.add(jsonCat[1][i]);
            }
          }
        });
      } else {
        // var jsonCat = jsonDecode(serverResp['response']);
        // messageToUser(_scaffoldKey, jsonCat[0]['message']);
      }
    });
  }

  void searchOperation(String searchText) {
    searchList.clear();
    _handleSearchStart();
    if (_isSearching != null) {
      for (int i = 0; i < userData.length; i++) {
        String data = userData[i].nombre;
        if (data.toLowerCase().contains(searchText.toLowerCase())) {
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
        : SingleChildScrollView(
            child: PaginatedDataTable(
            // header: const Text('Categorias'),
            header: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediaQuery.of(context).size.width < 700
                    ? Container()
                    : Expanded(
                        flex: 1,
                        child: Text(
                          'CATEGORÍAS',
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
            // availableRowsPerPage: const <int>[10],
            // onRowsPerPageChanged: (int value) {
            //   setState(() {
            //     _rowsPerPage = value;
            //   });
            // },
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.add,
                    color: primaryGreen,
                  ),
                  onPressed: () => _dialogCall(context))
            ],
            columns: kTableColumns,
            source: DessertDataSource(
                mycontext: context,
                dataCat: searchList.length == 0 ? userData : searchList),
          ));
  }

  Future<void> _dialogCall(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return MyDialog();
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
      'Fecha de registro',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Última actualización',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
];

////// Data source class for obtaining row data for PaginatedDataTable.
class DessertDataSource extends DataTableSource {
  BuildContext _context;
  dynamic _vendedorData;
  DessertDataSource({
    @required List<Cat> dataCat,
    @required BuildContext mycontext,
  })  : _vendedorData = dataCat,
        _context = mycontext,
        assert(dataCat != null);

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

    if (_user.estado == 'activa') {
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
          _dialogCall(_context, _user.categoria_id, _user);
        },
        cells: <DataCell>[
          DataCell(
            CircleAvatar(
              backgroundColor: Colors.grey[400],
              backgroundImage:
                  NetworkImage(_user.img_url == null ? "" : _user.img_url),
            ),
          ),
          DataCell(
            IconButton(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: iconStatus,
                onPressed: () {}),
          ),
          DataCell(Text('${_user.nombre}')),
          DataCell(Text('${_user.created_at}')),
          DataCell(Text('${_user.updated_at}')),
        ]);
  }

  Future<void> _dialogCall(BuildContext context, idCat, catInfo) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogInfo(
            catId: idCat,
            categoryInfo: catInfo,
          );
        });
  }

  @override
  int get rowCount => _vendedorData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => new _MyDialogState();
}

class DialogInfo extends StatefulWidget {
  DialogInfo({Key key, @required this.catId, @required this.categoryInfo})
      : super(key: key);

  final String catId;

  final dynamic categoryInfo;

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

  bool editP = false;

  bool loadInfo = true;

  VerdeService verdeService = VerdeService();

  String nombrecat;
  var mediaData;

  @override
  void initState() {
    super.initState();
    getSubCat();
    sharedPrefs.init();
  }

  getSubCat() async {
    sharedPrefs.init();
    // print(sharedPrefs.clientToken);
    await verdeService
        .getService(null, 'categorias/productos?categoria=${widget.catId}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        setState(() {
          jsonCat = respResponse[1];
          loadInfo = false;
        });
      }
    });
  }

  deleteCat() async {
    await verdeService
        .deleteService('categorias?id=${widget.catId}', sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      // dialog(false, context, respResponse['message'].toString());
      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: CategoryPage())),
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
                    'Detalles de la categoría',
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
                width: MediaQuery.of(context).size.width / 3,
                child: SingleChildScrollView(
                    child: new ListBody(
                  children: <Widget>[
                    Column(
                      children: [
                        Container(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[400],
                            backgroundImage: mediaData != null
                                ? MemoryImage(mediaData.data)
                                : NetworkImage(
                                    widget.categoryInfo.img_url == null
                                        ? ""
                                        : widget.categoryInfo.img_url),
                          ),
                        ),
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
                                        setState(() {});
                                      }),
                                ),
                              ),
                        Form(
                          key: _formKey,
                          child: SimpleTextField(
                              labelText: 'Nombre',
                              initValue: widget.categoryInfo.nombre,
                              inputType: 'generic',
                              enabled: editP,
                              onSaved: (value) => nombrecat = value,
                              textCapitalization: TextCapitalization.sentences),
                        ),
                        SizedBox(height: 20),
                        widget.categoryInfo.estado == 'inactiva'
                            ? Container()
                            : !editP
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
                                        postCat(
                                            widget.categoryInfo.categoria_id);
                                      }
                                    },
                                  ),
                        widget.categoryInfo.estado == 'inactiva'
                            ? Container()
                            : SizedBox(height: 20),
                        widget.categoryInfo.estado == 'inactiva'
                            ? Container()
                            : ButtonLight(
                                mainText: 'Ver subcategorias',
                                pressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SubCategoryPage(
                                              infoCat: widget.categoryInfo,
                                            )))),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: widget.categoryInfo.estado == 'inactiva'
                                  ? ButtonPrimary(
                                      mainText: 'Habilitar categoría',
                                      pressed: () => _showDesDialog(true),
                                    )
                                  : ButtonPrimary(
                                      mainText: 'Deshabilitar categoría',
                                      color: primaryOrange,
                                      pressed: () => _showDesDialog(false),
                                    ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => _showMyDialog(),
                                child: Text(
                                  'Eliminar categoría',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                )),
              ));
  }

  Future<void> _showDesDialog(bool active) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(!active ? 'Deshabilitar categoría' : 'Habilitar categoría'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                !active
                    ? Text(
                        'Se deshabilitará la categoría ${widget.categoryInfo.nombre} y sus productos.')
                    : Text(
                        'Se habilitará la categoría ${widget.categoryInfo.nombre} y sus productos.'),
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
              child: !active ? Text('Deshabilitar') : Text('Habilitar'),
              onPressed: () {
                !active ? desCat() : habCat();
              },
            ),
          ],
        );
      },
    );
  }

  desCat() async {
    await verdeService
        .postTokenService(
            null,
            'categorias/deshabilitar?id=${widget.categoryInfo.categoria_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      // dialog(false, context, respResponse['message'].toString());
      print(serverResp);
      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: CategoryPage())),
            (route) => false);
        dialog(true, context, respResponse['message'].toString());
      } else {
        dialog(false, context, respResponse['message'].toString());
      }
    });
  }

  habCat() async {
    await verdeService
        .postTokenService(
            null,
            'categorias/habilitar?id=${widget.categoryInfo.categoria_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      // dialog(false, context, respResponse['message'].toString());
      // print(serverResp);
      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: CategoryPage())),
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

  postCat(catID) async {
    VerdeService verdeService = VerdeService();

    var jsonBody = {
      "nombre": nombrecat,
      "img_url": mediaData == null ? null : base64Encode(mediaData.data),
      "nombre_archivo": mediaData == null ? null : mediaData.fileName,
      "tipo": "producto"
    };

    // print(jsonBody);

    await verdeService
        .postTokenService(
            jsonBody, 'categorias?id=$catID', sharedPrefs.clientToken)
        .then((serverResp) {
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
                    HomePage(rutaSeleccionada: CategoryPage())),
            (route) => false);
        dialog(true, context, respResponse['message'].toString());
      } else {
        dialog(false, context, respResponse['message'].toString());
      }
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar producto'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Se eliminara la categoría ${widget.categoryInfo.nombre} y todos sus productos.'),
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
              child: Text('Eliminar'),
              onPressed: () {
                deleteCat();
              },
            ),
          ],
        );
      },
    );
  }
}

class _MyDialogState extends State<MyDialog> {
  String imagePath;
  Image image;
  Image pickedImage;
  var base64image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String nombreCat;
  var mediaData;

  @override
  void initState() {
    super.initState();
    sharedPrefs.init();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Agregar categoría',
        style: TextStyle(color: Colors.black87),
      ),
      content: SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            Container(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[400],
                backgroundImage: mediaData != null
                    ? MemoryImage(mediaData.data)
                    : NetworkImage(''),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ButtonLight(
                    mainText: 'Seleccionar foto',
                    pressed: () async {
                      await pickImage();
                      setState(() {});
                    }),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SimpleTextField(
                      labelText: 'Nombre',
                      inputType: 'generic',
                      enabled: true,
                      onSaved: (value) => nombreCat = value,
                      textCapitalization: TextCapitalization.sentences)
                ],
              ),
            ),
          ],
        ),
      ),
      actionsPadding: EdgeInsets.all(10),
      actions: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ButtonPrimary(
              mainText: 'Agregar',
              pressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  postCat();
                }
              },
            ),
          ],
        )
      ],
    );
  }

  pickImage() async {
    mediaData = await ImagePickerWeb.getImageInfo;
    // print(pickedImage);
  }

  postCat() async {
    VerdeService verdeService = VerdeService();

    var jsonBody = {
      "nombre": nombreCat,
      "img_url": mediaData == null ? null : base64Encode(mediaData.data),
      "nombre_archivo": mediaData == null ? null : mediaData.fileName,
      "tipo": "producto"
    };

    // print(jsonBody);

    await verdeService
        .postTokenService(jsonBody, 'categorias', sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      // dialog(false, context, respResponse['message'].toString());
      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: CategoryPage())),
            (route) => false);
        dialog(true, context, 'Categoría agregada correctamente.');
      } else {
        dialog(false, context, respResponse['message'].toString());
      }
    });
  }
}
