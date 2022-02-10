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
import 'category_page.dart';

////// Data class.s
class SubCat {
  SubCat(this.nombre, this.categoria_id);
  final String nombre;
  final String categoria_id;
}

class SubCategoryPage extends StatefulWidget {
  SubCategoryPage({
    Key key,
    @required this.infoCat,
  }) : super(key: key);

  final dynamic infoCat;

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage>
    with TickerProviderStateMixin {
  var jsonVendedor;
  List<SubCat> userData = [];
  List<SubCat> searchList = [];

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
    // print('----');
    // print(widget.infoCat.nombre);
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();

    print(sharedPrefs.clientToken.toString());

    getSubCat().then((value) {
      for (var i = 0; i < category.length; i++) {
        // print(category[i]['nombre']);
        // print('----------------');
        userData.add(SubCat(
          category[i]['nombre'],
          category[i]['categoria_id'],
        ));
      }
      setState(() {
        loadInfo = false;
      });
    });

    super.initState();
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

  getSubCat() async {
    sharedPrefs.init();
    print(sharedPrefs.clientToken);
    await verdeService
        .getService(
            null,
            'categorias/productos?categoria=${widget.infoCat.categoria_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var jsonCat = jsonDecode(serverResp['response']);

        setState(() {
          for (int i = 0; i <= jsonCat[1].length - 1; i++) {
            category.add(jsonCat[1][i]);
          }
        });
      }
    });
  }

  @override
  Widget build(context) {
    int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
    return Scaffold(
        appBar: AppBar(
          title: Text('Subcategorias de ${widget.infoCat.nombre}'),
          backgroundColor: primaryGreen,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomePage(rutaSeleccionada: CategoryPage())),
                (route) => false),
          ),
        ),
        body: SafeArea(
            child: Center(
                child: Container(
          color: Colors.grey[200],
          width: MediaQuery.of(context).size.width - 200.0,
          child: loadInfo
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: primaryGreen,
                    valueColor: animationController.drive(
                        ColorTween(begin: primaryOrange, end: primaryYellow)),
                  ),
                )
              : SingleChildScrollView(
                  child: PaginatedDataTable(
                  // header: const Text('Categorias'),
                  header: MediaQuery.of(context).size.width < 700
                      ? Container()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RoundTextField(
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
                          ],
                        ),
                  showCheckboxColumn: false,
                  rowsPerPage: 5,
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
                      dataCat: searchList.length == 0 ? userData : searchList,
                      infoCat: widget.infoCat),
                )),
        ))));
  }

  Future<void> _dialogCall(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return MyDialog(
            catPadre: widget.infoCat,
          );
        });
  }
}

////// Columns in table.
const kTableColumns = <DataColumn>[
  DataColumn(
    label: Text(
      'Nombre',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
];

////// Data source class for obtaining row data for PaginatedDataTable.
class DessertDataSource extends DataTableSource {
  BuildContext _context;
  dynamic _vendedorData;
  dynamic _infoCat;
  DessertDataSource({
    @required List<SubCat> dataCat,
    @required dynamic infoCat,
    @required BuildContext mycontext,
  })  : _vendedorData = dataCat,
        _context = mycontext,
        _infoCat = infoCat,
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

    return DataRow.byIndex(index: index, // DONT MISS THIS
        cells: <DataCell>[
          DataCell(Row(
            children: [
              IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red[400],
                  ),
                  onPressed: () => _dialogCall(_context, _user, _infoCat)),
              SizedBox(
                width: 10,
              ),
              Text('${_user.nombre}')
            ],
          ))
        ]);
  }

  Future<void> _dialogCall(BuildContext context, catInfo, catPadre) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogDelete(
            categoryInfo: catInfo,
            categoryPadre: catPadre,
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

class DialogDelete extends StatefulWidget {
  DialogDelete(
      {Key key, @required this.categoryInfo, @required this.categoryPadre})
      : super(key: key);

  final dynamic categoryInfo;
  final dynamic categoryPadre;

  @override
  _DialogDeleteState createState() => new _DialogDeleteState();
}

class _DialogDeleteState extends State<DialogDelete> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  VerdeService verdeService = VerdeService();

  @override
  void initState() {
    super.initState();
    sharedPrefs.init();
  }

  deleteSub() async {
    await verdeService
        .deleteService('categorias?id=${widget.categoryInfo.categoria_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      var respResponse = jsonDecode(serverResp['response']);
      // dialog(false, context, respResponse['message'].toString());
      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => SubCategoryPage(
                      infoCat: widget.categoryPadre,
                    )),
            ModalRoute.withName('/home'));
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
                    'Eliminar subcategoría',
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
            Text(
              'Se eliminara la subcategoría ${widget.categoryInfo.nombre}',
              style: TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            MediaQuery.of(context).size.width < 360
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ButtonPrimary(
                          mainText: 'Cancelar',
                          pressed: () => Navigator.pop(context)),
                      SizedBox(height: 20),
                      ButtonLight(
                        mainText: 'Eliminar',
                        pressed: () => deleteSub(),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ButtonPrimary(
                          mainText: 'Cancelar',
                          pressed: () => Navigator.pop(context)),
                      SizedBox(width: 20),
                      ButtonLight(
                        mainText: 'Eliminar',
                        pressed: () => deleteSub(),
                      ),
                    ],
                  )
          ],
        )));
  }
}

class MyDialog extends StatefulWidget {
  MyDialog({Key key, @required this.catPadre}) : super(key: key);

  final dynamic catPadre;

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

  @override
  void initState() {
    super.initState();
    sharedPrefs.init();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'Agregar subcategoría',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
              icon: Icon(Icons.close), onPressed: () => Navigator.pop(context))
        ],
      ),
      content: SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
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
                  postsubCat();
                }
              },
            ),
          ],
        )
      ],
    );
  }

  postsubCat() async {
    VerdeService verdeService = VerdeService();

    var jsonBody = {
      "nombre": nombreCat,
      "categoria_padre_id": widget.catPadre.categoria_id,
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
                builder: (context) => SubCategoryPage(
                      infoCat: widget.catPadre,
                    )),
            ModalRoute.withName('/home'));
        dialog(true, context, respResponse['message'].toString());
      } else {
        dialog(false, context, respResponse['message'].toString());
      }
    });
  }
}
