import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lemari_lama/models/report.dart';

class ReportService {
  final String apiUrl = "http://192.168.0.113/lemari_lama/report/";

  Future<bool> addReport(String idUser, String alasan, String idProduk) async {
    final response = await http.post(
      Uri.parse(apiUrl + 'post.php'),
      body: {
        'id_pelapor': idUser,
        'id_produk': idProduk,
        'alasan': alasan,
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

  Future<List<ReportModel>> getAll() async {
    final response = await http.get(Uri.parse(apiUrl + 'get.php'));

    final result = json.decode(response.body);
    if (response.statusCode == 200 && result['status'] == true) {
      List data = result['data'];
      return data.map((item) => ReportModel.fromMap(item)).toList();
    } else {
      throw Exception(result['pesan']);
    }
  }
}