import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/global.dart';
import 'package:web_verde/src/pages/home_page.dart';
import 'package:web_verde/src/pages/vendedor_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/button_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';

////// Data class.s
class ProductoInfo {
  ProductoInfo(this.nombre, this.producto_id, this.imagenes, this.descripcion,
      this.precio, this.categoria_id, this.subcategoria_id);
  final String nombre;
  final String producto_id;
  final dynamic imagenes;
  final String descripcion;
  final String precio;
  final String categoria_id;
  final String subcategoria_id;
}

class ProductsPage extends StatefulWidget {
  ProductsPage({Key key, @required this.infoVendedor}) : super(key: key);

  final dynamic infoVendedor;

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  var jsonVendedor;
  List<ProductoInfo> productData = [];
  List<ProductoInfo> searchList = [];

  var category = [];

  VerdeService verdeService = VerdeService();
  AdminModel adminModel = AdminModel();
  bool loadInfo = true;
  AnimationController animationController;

  Image pickedImage;

  bool loadimage = true;

  bool _isSearching;

  var productosVendedor;

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

    // print(sharedPrefs.clientToken.toString())
    getServicio().then((value) {
      for (var i = 0; i < productosVendedor.length; i++) {
        print(productosVendedor[i]['nombre']);
        productData.add(ProductoInfo(
          productosVendedor[i]['nombre'],
          productosVendedor[i]['producto_id'],
          productosVendedor[i]['imagenes'],
          productosVendedor[i]['descripcion'],
          productosVendedor[i]['precio'],
          productosVendedor[i]['categoria_id'],
          productosVendedor[i]['subcategoria_id'],
        ));
      }
      setState(() {
        loadInfo = false;
      });
    });

    super.initState();
  }

  getServicio() async {
    sharedPrefs.init();
    await verdeService
        .getService(
            adminModel,
            'vendedor/productos?id=${widget.infoVendedor['usuario_id']}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        setState(() {
          productosVendedor = respResponse[1];
        });
      }
    });
  }

  void searchOperation(String searchText) {
    searchList.clear();
    _handleSearchStart();
    if (_isSearching != null) {
      for (int i = 0; i < userData.length; i++) {
        String data = productData[i].nombre;
        if (data.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            searchList.add(productData[i]);
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Productos de ${widget.infoVendedor['nombre']}'),
          backgroundColor: primaryGreen,
          leading: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: () =>  Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      rutaSeleccionada: Vendedor(),
                      labelInit: 'Vendedores'
                    )),
             (route) => false)),
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
                  header: Column(
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
                  // actions: [
                  //   IconButton(
                  //       icon: Icon(
                  //         Icons.add,
                  //         color: primaryGreen,
                  //       ),
                  //       onPressed: () => _dialogCall(context))
                  // ],
                  columns: kTableColumns,
                  source: DessertDataSource(
                      mycontext: context,
                      dataCat:
                          searchList.length == 0 ? productData : searchList,
                      infoVen: widget.infoVendedor),
                )),
        )))
        //
        );
  }

  Future<void> _dialogCall(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return MyDialog(
            catPadre: widget.infoVendedor,
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
  DataColumn(
    label: Text(
      'Descripcion',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
  DataColumn(
    label: Text(
      'Precio',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
];

////// Data source class for obtaining row data for PaginatedDataTable.
class DessertDataSource extends DataTableSource {
  BuildContext _context;
  dynamic _vendedorData;

  dynamic _venInfo;

  DessertDataSource({
    @required List<ProductoInfo> dataCat,
    @required BuildContext mycontext,
    @required dynamic infoVen,
  })  : _vendedorData = dataCat,
        _context = mycontext,
        _venInfo = infoVen,
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

    return DataRow.byIndex(
        onSelectChanged: (bool value) {
          _detailDialogCall(_context, _user);
        },
        index: index, // DONT MISS THIS
        cells: <DataCell>[
          DataCell(Row(
            children: [
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _dialogCall(_context, _user, _venInfo)),
              SizedBox(
                width: 10,
              ),
              Text('${_user.nombre}')
            ],
          )),
          DataCell(Container(
              width: 150,
              child: Text(
                '${_user.descripcion}',
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ))),
          DataCell(Text('\$ ${_user.precio} MXN')),
        ]);
  }

  Future<void> _dialogCall(BuildContext context, catInfo, venInfo) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogDelete(
            categoryInfo: catInfo,
            infoVen: venInfo,
          );
        });
  }

  Future<void> _detailDialogCall(BuildContext context, serviceInfo) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogInfo(serviceInfo: serviceInfo);
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

  var category;
  var subcategory;

  String catProduct;
  String subcatProduct;

  bool loadInfo = true;

  VerdeService verdeService = VerdeService();

  @override
  void initState() {
    super.initState();
    getCategory();
    sharedPrefs.init();
  }

  getCategory() async {
    await verdeService
        .getService(null, 'categorias/productos', sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        category = jsonDecode(serverResp['response']);
        // print(category[0]['message']);
        setState(() {
          for (int i = 0; i <= category[1].length - 1; i++) {
            if (category[1][i]['categoria_padre_id'] == null) {
              if (category[1][i]['categoria_id'] ==
                  widget.serviceInfo.categoria_id) {
                setState(() {
                  catProduct = category[1][i]['nombre'];
                });
                break;
              }
            }
          }
          getSubCategory();
        });
      }
    });
  }

  getSubCategory() async {
    await verdeService
        .getService(
            null,
            'categorias/productos?categoria=${widget.serviceInfo.categoria_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        subcategory = jsonDecode(serverResp['response']);
        // print(subcategory[0]['message']);
        setState(() {
          for (int i = 0; i <= subcategory[1].length - 1; i++) {
            if (subcategory[1][i]['categoria_id'] ==
                widget.serviceInfo.subcategoria_id) {
              setState(() {
                subcatProduct = subcategory[1][i]['nombre'];
                loadInfo = false;
              });
              break;
            }
          }
          setState(() {
            loadInfo = false;
          });
        });
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
                Text(
                  'Detalles del producto',
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
        content: SingleChildScrollView(
            child: new ListBody(
          children: <Widget>[
            loadInfo
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: primaryGreen,
                    ),
                  )
                : Column(
                    children: [
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
                      SimpleTextField(
                          labelText: 'Precio',
                          initValue: widget.serviceInfo.precio,
                          inputType: 'generic',
                          enabled: false,
                          onSaved: null,
                          textCapitalization: TextCapitalization.sentences),
                      SimpleTextField(
                          labelText: 'Categoría',
                          initValue: catProduct,
                          inputType: 'generic',
                          enabled: false,
                          onSaved: null,
                          textCapitalization: TextCapitalization.sentences),
                      SimpleTextField(
                          labelText: 'Subcategoría',
                          initValue: subcatProduct,
                          inputType: 'generic',
                          enabled: false,
                          onSaved: null,
                          textCapitalization: TextCapitalization.sentences),
                           SizedBox(height: 20),
                  widget.serviceInfo.imagenes.length == 0
                      ? Container()
                      : ButtonLight(
                          mainText: 'Ver imágenes',
                          pressed: () => _showMyDialog(widget.serviceInfo.nombre,
                              widget.serviceInfo.imagenes),
                        ),
                    ],
                  ),
          ],
        )));
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

class DialogDelete extends StatefulWidget {
  DialogDelete({Key key, @required this.categoryInfo, @required this.infoVen})
      : super(key: key);

  final dynamic categoryInfo;
  final dynamic infoVen;

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

  deleteProd() async {
    // print(widget.categoryInfo.producto_id);
    await verdeService
        .deleteService('productos?id=${widget.categoryInfo.producto_id}',
            sharedPrefs.clientToken)
        .then((serverResp) {
          var respResponse = jsonDecode(serverResp['response']);

      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ProductsPage(
                      infoVendedor: widget.infoVen,
                    )),
            ModalRoute.withName('/home'));
            dialog(true, context, respResponse['message']);
      } else{
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ProductsPage(
                      infoVendedor: widget.infoVen,
                    )),
            ModalRoute.withName('/home'));
        dialog(false, context, respResponse['message']);
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
                Text(
                  'Eliminar producto',
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
        content: SingleChildScrollView(
            child: new ListBody(
          children: <Widget>[
            Text(
              'Se eliminara el producto ${widget.categoryInfo.nombre}',
              style: TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ButtonLight(
                    mainText: 'Cancelar',
                    pressed: () => Navigator.pop(context)),
                SizedBox(width: 20),
                ButtonPrimary(
                  mainText: 'Eliminar',
                  pressed: () => deleteProd(),
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
          Text(
            'Agregar subcategoría',
            style: TextStyle(color: Colors.black87),
            textAlign: TextAlign.center,
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
        .then((serverResp) => {
              if (serverResp['status'] == 'server_true')
                {Navigator.pop(context)}
            });
  }
}
