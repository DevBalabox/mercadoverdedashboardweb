import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/button_widget.dart';
import 'package:web_verde/src/widgets/input_widget.dart';

class AnunciosModel {
  AnunciosModel(
    this.active,
    this.productos_id,
    this.imagen,
    this.anuncio_id,
    this.fechas,
    this.nombre_vendedor,
    this.nombre_producto,
  );
  final String active;
  final String productos_id;
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
    await verdeService.postTokenServiceMock({"anuncio_id": "string"},
        "enlistar/anuncios-admin", sharedPrefs.clientToken).then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var respAnuncios = jsonDecode(serverResp['response']);
        //anuncios = respAnuncios[1];
        print(respAnuncios[1][0]);
        print(respAnuncios[1][1]);

        setState(() {
          loadinfo = false;
          jsonAnuncios = respAnuncios[1];
          for (var i = 0; i < jsonAnuncios.length; i++) {
            anuncios.add(AnunciosModel(
              jsonAnuncios[i]['active'].toString(),
              jsonAnuncios[i]['productos_id'].toString(),
              jsonAnuncios[i]['imagen'].toString(),
              jsonAnuncios[i]['anuncio_id'].toString(),
              jsonAnuncios[i]['fechas'].toString(),
              jsonAnuncios[i]['nombre_vendedor'].toString(),
              jsonAnuncios[i]['nombre_producto'].toString(),
            ));
          }
          print('anuncios');
          print(anuncios[1]);
        });
      }
    });
  }

  final DataTableSource _data = MyData();

  @override
  Widget build(BuildContext context) {
    int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
    return loadinfo
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
            : ListView(children: [
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
                    actions: [
                      IconButton(
                          icon: Icon(
                            Icons.add,
                            color: primaryGreen,
                          ),
                          onPressed: () {} /* () => _dialogCall(context) */)
                    ],
                    columns: kTableColumns,
                    source: AnunciosDataSourceTable(
                      dataAnuncios: anuncios,
                      mycontext: context,
                    ),
                  ),
                ),
              ]);
  }
}

// The "soruce" of the table
class MyData extends DataTableSource {
  // Generate some made-up data
  final List<Map<String, dynamic>> _data = List.generate(
      200,
      (index) => {
            "id": index,
            "title": "Item $index",
            "price": Random().nextInt(10000)
          });

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_data[index]['id'].toString())),
      DataCell(Text(_data[index]["title"])),
      DataCell(Text(_data[index]["price"].toString())),
    ]);
  }
}

//Rows
/* class AnunciosDataSorce extends DataTableSource{
  @override
  DataRow getRow(int index) {
    // TODO: implement getRow
    throw UnimplementedError();
  }

  @override
 @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0; 
}
*/

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
      'Editar',
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
                  _detallesDialogCall(_context, _anuncio.productos_id);
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
                  _dialogCall(_context, _anuncio.productos_id);
                },
                child: Center(
                  child: Container(
                    child: Text('Editar',
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

Future _detallesDialogCall(BuildContext context, idAnuncio) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        print(idAnuncio);
        return DetallesDialog(idAnuncio: idAnuncio); //MyDialog();
      });
}

void searchOperation(String searchText) {
  //  searchList.clear();
  //  _handleSearchStart();
  //  if (_isSearching != null) {
  //    for (int i = 0; i < userData.length; i++) {
  //      String data = userData[i].nombre;
  //      if (data.toLowerCase().contains(searchText.toLowerCase())) {
  //        setState(() {
  //          searchList.add(userData[i]);
  //        });
  //      }
  //    }
  //  }
}

class DetallesDialog extends StatefulWidget {
  DetallesDialog({Key key, @required this.idAnuncio}) : super(key: key);
  final String idAnuncio;
  //final dinamyc idAnuncio;

  @override
  State<DetallesDialog> createState() => _DetallesDialogState();
}

class _DetallesDialogState extends State<DetallesDialog> {
  VerdeService verdeService = VerdeService();
  var anunciosDetalles;
  bool editP = false;

  bool loadInfo = true;
  String nombreAnuncio;
  var mediaData;
  String imagePath;
  Image image;
  Image pickedImage;
  var base64image;

  getAnuncioDetalles() async {
    await verdeService
        .getService(null, 'categorias/productos?categoria=${widget.idAnuncio}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        setState(() {
          anunciosDetalles = respResponse[1];
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
                Flexible(
                  child: Text(
                    'Anuncio #123',
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
                        Container(
                          child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[400],
                              backgroundImage: NetworkImage(
                                  'https://merkadoverdeapp.com/wp-content/uploads/2021/01/cover-2.jpg')
                              //mediaData != null
                              // MemoryImage(mediaData.data)
                              //? MemoryImage(mediaData.data)
                              //: NetworkImage(
                              //    widget.categoryInfo.img_url == null
                              //        ? ""
                              //        : widget.categoryInfo.img_url),
                              ),
                        ),
//                        !editP
//                            ? Container()
//                            : Padding(
//                                padding: const EdgeInsets.only(top: 5.0),
//                                child: Padding(
//                                  padding: const EdgeInsets.only(top: 5.0),
//                                  child: ButtonLight(
//                                      mainText: 'Seleccionar foto',
//                                      pressed: () async {
//                                        //await pickImage();
//                                        //setState(() {});
//                                      }),
//                                ),
//                              ),
                        Form(
                          //key: _formKey,
                          child: SimpleTextField(
                              labelText: 'Nombre',
                              initValue: 'Nombre', //widget.categoryInfo.nombre,
                              inputType: 'generic',
                              enabled: editP,
                              onSaved: (value) =>
                                  {}, //(value) => nombrecat = value,
                              textCapitalization: TextCapitalization.sentences),
                        ),
                        SizedBox(height: 20),
                        //widget.categoryInfo.estado == 'inactiva'
                        Container(
                          child: Form(
                            //key: _formKey,
                            child: SimpleTextField(
                                labelText: 'Nombre del vendedor/tienda',
                                initValue:
                                    'Roberto González', //widget.categoryInfo.nombre,
                                inputType: 'generic',
                                enabled: editP,
                                onSaved: (value) =>
                                    {}, //(value) => nombrecat = value,
                                textCapitalization:
                                    TextCapitalization.sentences),
                          ),
                        ),
//                            ? Container()
//                            : !editP
//                                ? ButtonPrimary(
//                                    mainText: 'Editar',
//                                    pressed: () => setState(() {
//                                      editP = true;
//                                    }),
//                                  )
//                                : ButtonPrimary(
//                                    mainText: 'Guardar',
//                                    pressed: () {
//                                      if (_formKey.currentState.validate()) {
//                                        _formKey.currentState.save();
//                                        postCat(
//                                            widget.categoryInfo.categoria_id);
//                                      }
//                                    },
//                                  ),
                        Container(
                            child: Form(
                          //key: _formKey,
                          child: SimpleTextField(
                              labelText: 'Fechas',
                              initValue:
                                  '1 de Febrero, 1 de Marzo', //widget.categoryInfo.nombre,
                              inputType: 'generic',
                              enabled: editP,
                              onSaved: (value) =>
                                  {}, //(value) => nombrecat = value,
                              textCapitalization: TextCapitalization.sentences),
                        )),
//                        widget.categoryInfo.estado == 'inactiva'
//                            ? Container()
//                            : SizedBox(height: 20),
                        Container(
                            child: Form(
                          //key: _formKey,
                          child: SimpleTextField(
                              labelText: 'Posicion unica',
                              initValue: '1', //widget.categoryInfo.nombre,
                              inputType: 'generic',
                              enabled: editP,
                              onSaved: (value) =>
                                  {}, //(value) => nombrecat = value,
                              textCapitalization: TextCapitalization.sentences),
                        )),
//                        widget.categoryInfo.estado == 'inactiva'
//                            ? Container()
//                            : ButtonLight(
//                                mainText: 'Ver subcategorias',
//                                pressed: () => Navigator.push(
//                                    context,
//                                    MaterialPageRoute(
//                                        builder: (context) => SubCategoryPage(
//                                              infoCat: widget.categoryInfo,
//                                            )))),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ButtonPrimary(
                                mainText: 'Editar',
                                pressed: () {},
                              ), /* => _showDesDialog(true) */

//                              child:
//                              widget.categoryInfo.estado == 'inactiva'
//                                  ? ButtonPrimary(
//                                      mainText: 'Habilitar categoría',
//                                      pressed: () {/* => _showDesDialog(true) */,
//                                    )
//                                  : ButtonPrimary(
//                                      mainText: 'Deshabilitar categoría',
//                                      color: primaryOrange,
//                                      pressed: (){} /* => _showDesDialog(false */),
//                                    ),
                            ),
//                            Expanded(
//                              child: InkWell(
//                                onTap: () {} /* => _showMyDialog() */,
//                                child: Text(
//                                  'Eliminar categoría',
//                                  textAlign: TextAlign.center,
//                                ),
//                              ),
//                            )
                          ],
                        )
                      ],
                    )
                  ],
                )),
              ));
  }
}
//}
