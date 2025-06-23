import 'package:lemari_lama/models/categories.dart';
import 'package:lemari_lama/models/users.dart';

class ProductModel {
  final String pid;
  final String nama;
  final int harga;
  final CategoriesModel kategori;
  final String gender;
  final String deskripsi;
  final UserModel pemilik;
  final String lokasi;
  final String alamat;
  final String gambar; 
  final bool is_active;

  ProductModel({
    required this.pid,
    required this.nama,
    required this.harga,
    required this.kategori,
    required this.gender,
    required this.deskripsi,
    required this.pemilik,
    required this.lokasi,
    required this.alamat,
    required this.gambar,
    required this.is_active,
  });

  // factory ProductModel.fromMap(Map<String, dynamic> data, String pid) {
  //   return ProductModel(
  //     pid: pid,
  //     nama: data['nama'] ?? '',
  //     harga: data['harga'] ?? 0,
  //     kategori: CategoriesModel.fromMap(data['kategori'], data['kategori']['kid']),
  //     gender: data['gender'] ?? '',
  //     deskripsi: data['deskripsi'] ?? '',
  //     pemilik: UserModel.fromMap(data['pemilik'], data['pemilik']['uid']),
  //     lokasi: data['lokasi'] ?? '',
  //     alamat: data['alamat'] ?? '',
  //     gambar: data['gambar'] ?? '',
  //     is_active: data['is_active'] ?? false,
  //   );
  // }
  factory ProductModel.fromMapWithResolvedData({
    required Map<String, dynamic> data,
    required String pid,
    required CategoriesModel kategori,
    required UserModel pemilik,
  }) {
    return ProductModel(
      pid: pid,
      nama: data['nama'] ?? '',
      harga: data['harga'] ?? 0,
      kategori: kategori,
      gender: data['gender'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      pemilik: pemilik,
      lokasi: data['lokasi'] ?? '',
      alamat: data['alamat'] ?? '',
      gambar: data['gambar'] ?? '',
      is_active: data['is_active'] ?? false,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'harga': harga,
      'kategori': kategori.kid,
      'gender': gender,
      'deskripsi': deskripsi,
      'pemilik': pemilik.uid,
      'lokasi': lokasi,
      'alamat': alamat,
      'gambar': gambar,
      'is_active': is_active,
    };
  }
}
