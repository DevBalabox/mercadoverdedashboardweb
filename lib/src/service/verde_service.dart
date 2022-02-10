import 'dart:convert';

import 'package:http/http.dart' show Client;

String urlApi = 'https://api.merkadoverdeapp.com/';

class VerdeService {
  Client client = Client();

  Future<dynamic> getService(dynamic model, String ruta, String token) async {
    String requestStatus = "local_false";
    String requestResponse = "Hubo un error local para procesar la petición";
    final response = await client.get(
      '$urlApi$ruta',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // print(response.body);

    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonResponse.length == 4) {
         if (jsonResponse['status'] == "true") {
          requestStatus = "server_true";
          requestResponse = jsonEncode(jsonResponse);
          // print("Todo bien:" + jsonResponse.toString());
        } else {
          requestStatus = "server_false";
          requestResponse = jsonEncode(jsonResponse);
          // print("Hay un problema: " + jsonResponse['message'].toString());
        }
      } else {
        if (jsonResponse[0]['status'] == "true") {
          requestStatus = "server_true";
          requestResponse = jsonEncode(jsonResponse);
          // print("Todo bien:" + jsonResponse.toString());
        } else {
          requestStatus = "server_false";
          requestResponse = jsonEncode(jsonResponse);
          // print("Hay un problema: " + jsonResponse[0]['message'].toString());
        }
      }
    } else {
      requestStatus = "server_false";
      requestResponse = jsonEncode(jsonResponse);
      // print("Hubo un problema para realizar la petición");
      // print(response.body);
    }

    return {"status": requestStatus, "response": requestResponse};
  }

  Future<dynamic> postService(dynamic model, String ruta) async {
    String requestStatus = "local_false";
    String requestResponse = "Hubo un error local para procesar la petición";
    final response = await client.post('$urlApi$ruta',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(model.toJson()));

    var jsonResponse = jsonDecode(response.body);
    String status;
    String message;
    if (jsonResponse.length == 2) {
      status = jsonResponse[0]['status'];
      message = jsonResponse[0]['message'];
    } else {
      status = jsonResponse['status'];
      message = jsonResponse['message'];
    }
    if (response.statusCode == 200) {
      if (status == "true") {
        requestStatus = "server_true";
        requestResponse = jsonEncode(jsonResponse);
        // print("Todo bien:" + jsonResponse.toString());
      } else {
        requestStatus = "server_false";
        requestResponse = jsonEncode(jsonResponse);
        // print("Hay un problema: " + message);
      }
    } else {
      requestStatus = "server_false";
      requestResponse = jsonEncode(jsonResponse);
      // print("Hubo un problema para realizar la petición");
      // print(response.body);
    }

    return {"status": requestStatus, "response": requestResponse};
  }


  Future<dynamic> postTokenService(dynamic model, String ruta, String token) async {
    String requestStatus = "local_false";
    String requestResponse = "Hubo un error local para procesar la petición";
    final response = await client.post('$urlApi$ruta',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(model));

    // print(response.body);

    var jsonResponse = jsonDecode(response.body);
    String status;
    String message;
    if (jsonResponse.length == 2) {
      status = jsonResponse[0]['status'];
      message = jsonResponse[0]['message'];
    } else {
      status = jsonResponse['status'];
      message = jsonResponse['message'];
    }
    if (response.statusCode == 200) {
      if (status == "true") {
        requestStatus = "server_true";
        requestResponse = jsonEncode(jsonResponse);
        // print("Todo bien:" + jsonResponse.toString());
      } else {
        requestStatus = "server_false";
        requestResponse = jsonEncode(jsonResponse);
        // print("Hay un problema: " + message);
      }
    } else {
      requestStatus = "server_false";
      requestResponse = jsonEncode(jsonResponse);
      // print("Hubo un problema para realizar la petición");
      // print(response.body);
    }

    return {"status": requestStatus, "response": requestResponse};
  }

  Future<dynamic> deleteService(String ruta, String token) async {
    String requestStatus = "local_false";
    String requestResponse = "Hubo un error local para procesar la petición";
    final response = await client.delete('$urlApi$ruta',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
    );

    var jsonResponse = jsonDecode(response.body);
    String status;
    String message;
    if (jsonResponse.length == 2) {
      status = jsonResponse[0]['status'];
      message = jsonResponse[0]['message'];
    } else {
      status = jsonResponse['status'];
      message = jsonResponse['message'];
    }
    if (response.statusCode == 200) {
      if (status == "true") {
        requestStatus = "server_true";
        requestResponse = jsonEncode(jsonResponse);
        // print("Todo bien:" + jsonResponse.toString());
      } else {
        requestStatus = "server_false";
        requestResponse = jsonEncode(jsonResponse);
        // print("Hay un problema: " + message);
      }
    } else {
      requestStatus = "server_false";
      requestResponse = jsonEncode(jsonResponse);
      // print("Hubo un problema para realizar la petición");
      // print(response.body);
    }

    return {"status": requestStatus, "response": requestResponse};
  }
}
