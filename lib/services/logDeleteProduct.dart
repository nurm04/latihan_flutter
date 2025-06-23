import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lemari_lama/models/logDeleteProduct.dart';

class LogDeleteProductService {
  final String apiUrl = "http://192.168.0.113/lemari_lama/logDeleteProduct/";

  Future<bool> add(String alasan, String idProduk) async {
    final response = await http.post(
      Uri.parse(apiUrl + 'post.php'),
      body: {
        'id_produk': idProduk,
        'alasan': alasan,
      },
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200 && result['status'] == true) {
      return true;
    } else {
      throw Exception(result['pesan']);
    }
  }

  Future<List<LogDeleteProductModel>> getAll() async {
    final response = await http.get(Uri.parse(apiUrl + 'get.php'));

    final result = json.decode(response.body);
    if (response.statusCode == 200 && result['status'] == true) {
      List data = result['data'];
      return data.map((item) => LogDeleteProductModel.fromMap(item)).toList();
    } else {
      throw Exception(result['pesan']);
    }
  }
}