import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/model/partner_model.dart';
import 'package:web_verde/src/global.dart';
import 'package:web_verde/src/pages/announcements_page.dart';
import 'package:web_verde/src/pages/home_page.dart';
import 'package:web_verde/src/pages/vendedor_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:web_verde/src/widgets/dropdown_formfield.dart';

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

class UsuariosVendedor {
  UsuariosVendedor(
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
    this.deleted_a,
  );
  final String nombre;
  final String primer_apellido;
  final String segundo_apellido;
  final String correo;
  final String telefono;
  final String ubicacion;
  final String img_url;
  final String usuario_id;
  final String created_at;
  final String updated_at;
  final String deleted_a;

  @override
  String toString() {
    return '$nombre, $primer_apellido , $segundo_apellido, $segundo_apellido, $correo, $telefono, $ubicacion, $img_url, $usuario_id, $created_at, $updated_at, $deleted_a';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is UsuariosVendedor &&
        other.nombre == nombre &&
        other.primer_apellido == primer_apellido &&
        other.segundo_apellido == segundo_apellido &&
        other.correo == correo &&
        other.telefono == telefono &&
        other.ubicacion == ubicacion &&
        other.img_url == img_url &&
        other.usuario_id == usuario_id &&
        other.created_at == created_at &&
        other.updated_at == updated_at &&
        other.deleted_a == deleted_a;
  }

  @override
  int get hashCode => hashValues(
      nombre,
      primer_apellido,
      segundo_apellido,
      segundo_apellido,
      correo,
      telefono,
      ubicacion,
      img_url,
      usuario_id,
      created_at,
      updated_at,
      deleted_a);
}

//Clase  Personas

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
  List<UsuariosVendedor> vendedorData = [];
  List<Partner> searchList = [];
  List<String> vendedors = [];
  List<String> idvendedors = [];
  List<String> listaFechas = [];
  List<Widget> addFechas = [];

  List<dynamic> productsForm = [];

  String idVendedor;
  bool mostrar;
  String idProducto;
  bool imagenCargada = false;
  var imagesBody;

//Variables Imagenes
  var mediaData;
  String imagePath;
  Image image;
  Image pickedImage;
  var base64image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loadInfo = true;

//Variables Productos
  var productosVendedor;
  List<ProductoInfo> productData = [];

  getProductoVendedor() async {
    await verdeService
        .getService(
            partnerModel, 'vendedor/productos', sharedPrefs.partnerUserToken)
        //partnerModel, 'vendedor/productos?usuario_id = ', sharedPrefs.partnerUserToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var newproducts = jsonDecode(serverResp['response']);
        print(newproducts[1]);
        setState(() {
          loadInfo = false;
        });
      } else {}
    });
  }

  void _addDatedWidget() {
    setState(() {
      addFechas.add(_datePickerForm());
    });
  }

  void _removeDatedWidget() {
    setState(() {
      addFechas.removeLast();
      listaFechas.removeLast();
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
        //print(respResponse[1]);
        setState(() {
          jsonVendedor = respResponse[1];
        });
      }
    });
  }

  postAnuncio() async {
    var jsonBody = {
      "imagenes": [
        {
          "nombre_archivo": mediaData == null ? null : mediaData.fileName,
          "img_url": mediaData == null ? null : base64Encode(mediaData.data)
        }
      ],
      "producto_id": idProducto,
      "fechas": listaFechas
    };

    //print(jsonBody['imagenes']);
    //print(jsonBody['producto_id']);
    //print(jsonBody['fechas']);

    //var json = jsonEncode(jsonBody);
    //print(json);

    await verdeService
        .postTokenService(jsonBody, "crear/anuncio", sharedPrefs.clientToken)
        .then((serverResp) {
      print('aquí va el jsonbody');
      print(jsonBody);
      var respResponse = jsonDecode(serverResp['response']);
      print(respResponse);
      if (serverResp['status'] == 'server_true') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(rutaSeleccionada: AnnouncementsPage())),
            (route) => false);
        print(respResponse[0]);
        dialog(true, context, respResponse.toString());
      } else {
        dialog(false, context, respResponse.toString());
      }
    });
  }

  @override
  void initState() {
    print(sharedPrefs.clientToken.toString());
    mostrar = false;
    getUser().then((value) {
      for (var i = 0; i < jsonVendedor.length; i++) {
        // print(jsonVendedor[i]['nombre'].toString());
        // print('----------------');
        vendedorData.add(UsuariosVendedor(
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

        vendedors.add((jsonVendedor[i]['nombre']).toString());
      }
      print(vendedorData[1].nombre);
      //String _displayStringForOption(Partner option) => option.nombre;
      setState(() {
        loadInfo = false;
      });
    });

    getProductoVendedor();
    super.initState();
  }

  getProductos(idUsuario) async {
    sharedPrefs.init();
    await verdeService
        .getService(
            adminModel,
            //'vendedor/productos?id=${jsonVendedor['usuario_id']}',
            'vendedor/productos?id=${idUsuario}',
            sharedPrefs.clientToken)
        .then((serverResp) {
      if (serverResp['status'] == 'server_true') {
        var respResponse = jsonDecode(serverResp['response']);
        // print(respResponse[1]);
        setState(() {
          for (var i = 0; i < respResponse[1].length; i++) {
            productsForm.add({
              "nombre": respResponse[1][i]["nombre"],
              "producto_id": respResponse[1][i]["producto_id"]
            });
          }
          productosVendedor = respResponse[1];

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
          print("productData");
        });
      }
    });
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
                    //Scaffold.of(context).openDrawer();
                    Navigator.pop(context);
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
                          height: 10,
                        ),
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
                                    borderRadius: BorderRadius.circular(18.0),
                                  ))),
                                  onPressed: () {
                                    _removeDatedWidget();
                                  },
                                  child: Center(
                                      child: Container(
                                    child:
                                        Icon(Icons.remove, color: Colors.white),
                                  )),
                                ))
                            : Container(),
                        SizedBox(
                          height: 30,
                        ),
                        Container(child: Text('Nombre Vendedor')),
//                        AutocompleteVendedor(
//                          vendedoresLista: vendedors,
//                        ),
                        ///////////////////////////////////7
                        StatefulBuilder(
                          builder: (BuildContext context, setState) {
                            String _displayStringForOption(
                                    UsuariosVendedor option) =>
                                option.nombre;
                            print('option.nombre');
                            //print();
                            return Autocomplete<UsuariosVendedor>(
                              displayStringForOption: _displayStringForOption,
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<
                                      UsuariosVendedor>.empty();
                                }
                                return this
                                    .vendedorData
                                    .where((UsuariosVendedor option) {
                                  return option.toString().contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (UsuariosVendedor selection) {
                                debugPrint(
                                    'You just selected $selection.usuario_id');
                                debugPrint(
                                    'You just selected ${_displayStringForOption(selection)}');

                                print(selection.usuario_id.toString());
                                print(selection.usuario_id);
                                setState(() {
                                  idVendedor = selection.usuario_id;
                                  mostrar = true;
                                  getProductos(idVendedor);
                                });
                              },
                            );
                          },
                        ),
                        /////////////////////////77
                        SizedBox(
                          height: 10,
                        ),
                        (mostrar != true)
                            ? Container()
                            : DropDownFormField(
                                hintText: 'Selecciona un producto',
                                contentPadding: const EdgeInsets.all(0),
                                filled: false,
                                titleText: 'Nombre del producto',
                                value: idProducto,
                                onSaved: (value) {
                                  setState(() {
                                    idProducto = value;
                                    print(idProducto);
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    idProducto = value;
                                    print(idProducto);
                                    // productModel.subcategoria_id = value;
                                  });
                                },
                                dataSource: productsForm,
                                textField: 'nombre',
                                valueField: 'producto_id',
                              ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (mediaData != null)
                            ? Container(
                                height: 250,
                                decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                  image: MemoryImage(mediaData.data),
                                  fit: BoxFit.fitHeight,
                                )))
                            : DottedBorder(
                                color: Colors.black,
                                strokeWidth: 1,
                                child: Container(
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    //mainAxisAlignment: MainAxisAlignment.center,
                                    //crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          height: 250,
                                          color: Color(0XFFFDFDFD)),
                                      Column(
                                        children: [
                                          Text(
                                              'Sube una imagen para tu anuncio',
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
                                                color: Colors.black
                                                    .withOpacity(0.5)),
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
                              onPressed: () async {
                                await pickImage();
                                setState(() {
                                  imagenCargada = true;
                                });
                              },
                              child: Center(
                                child: Container(
                                  child: Text('Subir Imagen',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )),
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
                                postAnuncio();
                              },
                              child: Center(
                                child: Container(
                                  child: Text('Crear Anuncio',
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
        String hola = selection;
        print('hola $hola');
        return hola;
      },
    );
  }
}

class AutocompleteProductos extends StatelessWidget {
  final List<String> productosLista;

  const AutocompleteProductos({this.productosLista});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return this.productosLista.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
      },
    );
  }
}
