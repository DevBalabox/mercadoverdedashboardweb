import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/model/partner_model.dart';
import 'package:web_verde/src/pages/vendedor_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class CreateAnnouncement extends StatefulWidget {
  CreateAnnouncement({Key key}) : super(key: key);

  @override
  State<CreateAnnouncement> createState() => _CreateAnnouncementState();
}

class _CreateAnnouncementState extends State<CreateAnnouncement> {
  AdminModel adminModel = AdminModel();
  VerdeService verdeService = VerdeService();
  PartnerModel partnerModel = PartnerModel();

  var jsonVendedor;
  List<Partner> userData = [];
  List<Partner> searchList = [];
  List<String> vendedors = [];
  List<String> listaFechas = [];
  List<Widget> addFechas = [];

//Variables Imagenes
  var mediaData;
  String imagePath;
  Image image;
  Image pickedImage;
  var base64image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loadInfo = true;

  getProductoVendedor() async {
//    setState(() {
//      loadProducts = false;
//      // if (subcategorie.length > 0) {
//      //   subValue = subcategorie[0];
//      // }
//      productsForm = [];
//    });
    await verdeService
        .getService(
            partnerModel, 'vendedor/productos', sharedPrefs.partnerUserToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var newproducts = jsonDecode(serverResp['response']);
        print(newproducts[1]);
        setState(() {
          loadInfo = false;
        });
      } else {
        // setState(() {
        //   loadPartner = false;
        //   noProduct = true;
        // });
        // var jsonCat = jsonDecode(serverResp['response']);
        // messageToUser(_scaffoldKey, jsonCat[0]['message']);
      }
    });
  }

  void _addDatedWidget() {
    setState(() {
      addFechas.add(_datePickerForm());
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
          print(val);
          listaFechas.add(val);
          print(listaFechas);
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

  pickImage() async {
    mediaData = await ImagePickerWeb.getImageInfo;
    // print(pickedImage);
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

  postAnuncio() async {
    setState(() {});
    var jsonBody = {
      "imagenes": mediaData == null ? null : base64Encode(mediaData.data),
      "producto_id": '', //_myActivity,
      "fechas": listaFechas
    };
    var json = jsonEncode(jsonBody);
    print(json);
  }

  @override
  void initState() {
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

        vendedors.add((jsonVendedor[i]['nombre'] +
            ' ' +
            (jsonVendedor[i]['primer_apellido']) +
            ' ' +
            (jsonVendedor[i]['segundo_apellido']).toString()));
      }

      //print(userData.toList());
      //print(vendedors);
      setState(() {
        loadInfo = false;
      });
    });

    getProductoVendedor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            ),
            actions: [
              SizedBox(
                width: 300,
              )
            ],
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              'CREAR ANUNCIOS',
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: primaryGreen,
                  fontSize: 25),
            ),
          ),
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(child: Text('Asignar fechas')),
                        Column(
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: addFechas.length,
                                itemBuilder: (context, index) {
                                  return addFechas[index];
                                }),
                          ],
                        ),
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
                                borderRadius: BorderRadius.circular(18.0),
                              ))),
                              onPressed: () {
                                _addDatedWidget();
                              },
                              child: Center(
                                  child: Container(
                                child: Icon(Icons.add, color: Colors.white),
                              )),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        Container(child: Text('Nombre Vendedor')),
                        AutocompleteVendedor(
                          vendedoresLista: vendedors,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(child: Text('Producto')),
                        AutocompleteVendedor(
                          vendedoresLista: vendedors,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        DottedBorder(
                          color: Colors.black,
                          strokeWidth: 1,
                          child: Container(
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              //mainAxisAlignment: MainAxisAlignment.center,
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    height: 250, color: Color(0XFFFDFDFD)),
                                Column(
                                  children: [
                                    Text('Sube una imagen para tu anuncio',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFF515151))),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Png y Jpg Horizontal',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFF979797))),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Icon(Icons.photo_library,
                                          size: 35,
                                          color: Colors.black.withOpacity(0.5)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
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
                                borderRadius: BorderRadius.circular(18.0),
                              ))),
                              onPressed: () {},
                              child: Center(
                                child: Container(
                                  child: Text('Detalles',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class AutocompleteVendedor extends StatelessWidget {
  final List<String> vendedoresLista;

  const AutocompleteVendedor({this.vendedoresLista});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return this.vendedoresLista.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
      },
    );
  }
}
