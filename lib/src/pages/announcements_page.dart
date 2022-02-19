import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/widgets/input_widget.dart';

class AnnouncementsPage extends StatefulWidget {
  AnnouncementsPage({Key key}) : super(key: key);

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage>
    with TickerProviderStateMixin {
  bool loadinfo = true;
  AnimationController animationController;

  var anuncios = [];

//Variables de modelos
  VerdeService verdeService = VerdeService();
  AdminModel adminModel = AdminModel();

  @override
  void initState() {
    getAnuncios();
    super.initState();
  }

//Funcion para obtener anuncios
  getAnuncios() async {
    await verdeService.postTokenServiceMock({"anuncio_id": "string"},
        "enlistar/anuncios-admin", sharedPrefs.clientToken).then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var jsonAnuncios = jsonDecode(serverResp['response']);
        anuncios = jsonAnuncios;
        //print(anuncios);

        setState(() {
          for (int i = 0; i <= anuncios.length - 1; i++) {
            //loadinfo = false;

            anuncios.add(anuncios[1][i]);
            print('$anuncios $i');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
    return loadinfo
        ? Center(
            child: CircularProgressIndicator(
              backgroundColor: primaryGreen,
              // valueColor: animationController
              //     .drive(ColorTween(begin: primaryOrange, end: primaryYellow)),
            ),
          )
        : SingleChildScrollView(
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
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.add,
                    color: primaryGreen,
                  ),
                  onPressed: () => _dialogCall(context))
            ],
            columns: kTableColumns,
            //source:  //AnunciosDataSourceTable(mycontext: context, dataAnuncios: [] /* anuncios */),
          ));
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
  DataColumn(
    label: Text(
      'Última actualización',
      style: TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
];

class AnunciosDataSourceTable extends DataTableSource {
  BuildContext _context;
  dynamic _anunciosData;

  AnunciosDataSourceTable(
      {@required List dataAnuncios, @required BuildContext mycontext})
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

    if (_anuncio.estado == 'activa') {
      iconStatus = Icon(
        Icons.check,
        color: primaryGreen,
      );
    } else {
      iconStatus = Icon(Icons.close, color: primaryOrange);
    }

    return DataRow.byIndex(
        index: index,
        onSelectChanged: (bool value) {},
        cells: <DataCell>[
//          DataCell(
//            CircleAvatar(
//              backgroundColor: Colors.grey[400],
//              backgroundImage: NetworkImage(_anuncio.imagen == null
//                  ? "https://merkadoverdeapp.com/wp-content/uploads/2021/03/Isotipo_Verde_MV1.png"
//                  : _anuncio.img_url),
//            ),
//          ),
          DataCell(Text('$_anuncio.nombre_producto')),
          DataCell(Text('$_anuncio.nombre_vendedor')),
          DataCell(Text('$_anuncio.nombre_vendedor')),
          DataCell(Text('$_anuncio.nombre_vendedor')),
          DataCell(Text('$_anuncio.nombre_vendedor')),
          DataCell(Text('$_anuncio.nombre_vendedor')),
          //DataCell(Text('$_anuncio.')),
        ]);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => throw UnimplementedError();

  @override
  // TODO: implement rowCount
  int get rowCount => throw UnimplementedError();

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => throw UnimplementedError();
}

Future<void> _dialogCall(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return; //MyDialog();
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
