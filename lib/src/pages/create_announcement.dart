import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/pages/vendedor_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/utils/theme.dart';
import 'package:web_verde/src/service/verde_service.dart';

class CreateAnnouncement extends StatefulWidget {
  CreateAnnouncement({Key key}) : super(key: key);

  @override
  State<CreateAnnouncement> createState() => _CreateAnnouncementState();
}

class _CreateAnnouncementState extends State<CreateAnnouncement> {
  AdminModel adminModel = AdminModel();
  VerdeService verdeService = VerdeService();

  var jsonVendedor;
  List<Partner> userData = [];
  List<Partner> searchList = [];
  List<String> vendedors = [];

  String imagePath;
  Image image;
  Image pickedImage;
  var base64image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loadInfo = true;

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
      print(vendedors);
      setState(() {
        loadInfo = false;
      });
    });

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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                                decoration: const InputDecoration(
                              icon: Icon(Icons.person),
                              hintText: 'Vendedor',
                              labelText: 'Name *',
                            )),
                            AutocompleteVendedor(
                              vendedoresLista: vendedors,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity / 2,
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
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
