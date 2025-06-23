// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:lemari_lama/component/Judul.dart';
import 'package:lemari_lama/services/logDeleteProduct.dart';
import 'package:photo_view/photo_view.dart';

import 'package:lemari_lama/models/users.dart';
import 'package:lemari_lama/models/products.dart';
import 'package:lemari_lama/models/report.dart';

import 'package:lemari_lama/services/user.dart';
import 'package:lemari_lama/services/produk.dart';
import 'package:lemari_lama/services/report.dart';

class Reportpage extends StatefulWidget {
  const Reportpage({super.key});

  @override
  State<Reportpage> createState() => _ReportpageState();
}

class _ReportpageState extends State<Reportpage> {
  bool isLoading = true;

  void initState() {
    super.initState();
    fetchAllData();
  }

  ReportService _reportService = ReportService();
  List<ReportModel> logReportProducts = [];
  final _userService = UserService();
  Map<String, UserModel?> userData = {};
  final _produkService = ProductService();
  Map<String, ProductModel?> produkData = {};

  Future<void> fetchAllData() async {
    final report = await _reportService.getAll();
    Map<String, UserModel?> userMap = {};
    Map<String, ProductModel?> produkMap = {};

    for (var log in report) {
      final idProduk = log.id_produk;
      final idUser = log.id_pelapor;

      if (idProduk == null && idUser == null) continue;

      final user = await _userService.getUser(idUser);
      userMap[idUser] = user;

      final produk = await _produkService.getProduct(idProduk);
      produkMap[idProduk] = produk;
    }

    setState(() {
      logReportProducts = report;
      userData = userMap;
      produkData = produkMap;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 240, 240),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Judul(title: 'Komentar User'),
                    const SizedBox(height: 10),
                    if (isLoading)
                      Center(child: CircularProgressIndicator(color: Color(0xFF544C2A),))
                    else if (logReportProducts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Text('Tidak ada data.'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: logReportProducts.length,
                        itemBuilder: (_, index) {
                          final dataLog = logReportProducts[index];
                          final user = userData[dataLog.id_pelapor];
                          final produk = produkData[dataLog.id_produk];

                          if (produk == null) {
                            return Text('Pesan tidak ditemukan');
                          }

                          return kontenbesar(context, dataLog, user!, produk);
                        },
                      ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget kontenbesar(BuildContext context, log, UserModel user, ProductModel produk) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black,
                      child: PhotoView(
                        imageProvider: NetworkImage(produk.gambar),
                        backgroundDecoration: BoxDecoration(color: Colors.black),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      ),
                    ),
                  ),
                ),
              );
            },
            child:Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF544C2A),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  produk.gambar,
                  width: 84,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk.nama,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF544C2A)
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Pelapor: " + user.nama,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Alasan: " + log.alasan,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Status: " + (produk.is_active?"Aktif":"Dinonaktifkan"),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(Icons.remove_red_eye, color: Color(0xFF544C2A)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      titlePadding: EdgeInsets.only(top: 16, left: 20, right: 8),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Detail', style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDetailRow('Nama Produk', produk.nama),
                          _buildDetailRow('Pemilik', produk.pemilik.nama),
                          _buildDetailRow('Gender', produk.gender),
                          _buildDetailRow('Kategori', produk.kategori.nama),
                          _buildDetailRow('Harga', 'Rp ${produk.harga}'),
                          _buildDetailRow('Deskripsi', produk.deskripsi),
                          _buildDetailRow('Pe;apor', user.nama),
                          _buildDetailRow('Alasan', log.alasan),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFB5AA7E),
                            ),
                            onPressed: () { 
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    titlePadding: EdgeInsets.only(top: 16, left: 20, right: 8),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: Icon(Icons.close),
                                          onPressed: () {
                                            Navigator.of(context, rootNavigator: true).pop();
                                          }
                                        ),
                                      ],
                                    ),
                                    content: Text("Yakin ingin dihapus?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          reportProduct(log.alasan, produk);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Iya', 
                                          style: TextStyle(
                                            color: Color(0xFF544C2A)
                                          )
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.delete, color: Colors.white,),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> reportProduct(text, ProductModel product) async {
    LogDeleteProductService _LogDeleteProductService = LogDeleteProductService();
    await _LogDeleteProductService.add(text, product.pid);
    final productService = ProductService();
    await productService.updateProduct(product.pid, {
      'is_active': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Produk berhasil dilaporkan'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 3),
      ),
    );

    fetchAllData();
  }
}