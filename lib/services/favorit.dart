import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lemari_lama/models/favorit.dart';

class FavoritService {
  final String apiUrl = "http://192.168.0.113/lemari_lama/favorit/";

  Future<bool> addFavorit(String idUser, String idProduk) async {
    final response = await http.post(
      Uri.parse(apiUrl + 'post.php'),
      body: {
        'id_user': idUser,
        'id_produk': idProduk,
      },
    );
    debugPrint('Response body:\n${response.body}');
    final result = json.decode(response.body);
    if (response.statusCode == 200 && result['status'] == true) {
      return true;
    } else {
      throw Exception(result['pesan']);
    }
  }

  Future<List<FavoritModel>> getByIdUser(String idUser) async {
    final response = await http.post(
      Uri.parse(apiUrl + 'getByIdUser.php'),
      body: {'id_user': idUser},
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200 && result['status'] == true) {
      List data = result['data'];
      return data.map((item) => FavoritModel.fromMap(item)).toList();
    } else {
      throw Exception(result['pesan']);
    }
  }

  Future<bool> deleteFavorit(String idUser, String idProduk) async {
    final response = await http.post(
      Uri.parse(apiUrl + 'delete.php'),
      body: {
        'id_user': idUser,
        'id_produk': idProduk,
      },
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200 && result['status'] == true) {
      return true;
    } else {
      throw Exception(result['pesan']);
    }
  }
}