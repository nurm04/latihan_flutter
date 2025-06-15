import 'package:flutter/material.dart';
import 'package:lemari_lama/component/Judul.dart';

import 'package:lemari_lama/helper/db_helper.dart';
import 'package:lemari_lama/models/products.dart';
import 'package:lemari_lama/services/produk.dart';
import 'package:photo_view/photo_view.dart';

class Riwayatprodukpage extends StatefulWidget {
  const Riwayatprodukpage({super.key});

  @override
  State<Riwayatprodukpage> createState() => _RiwayatprodukpageState();
}

class _RiwayatprodukpageState extends State<Riwayatprodukpage> {
  List<Map<String, dynamic>> logDeletedProducts = [];
  Map<String, ProductModel?> produkData = {};
  final _produkService = ProductService();
  bool isLoading = true;

  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    final deleted = await DBHelper.getAllDeletedProductsLog();
    Map<String, ProductModel?> produkMap = {};

    for (var log in deleted) {
      final idProduk = log['id_produk'];
      if (idProduk == null) continue;
      final produk = await _produkService.getProduct(idProduk);
      produkMap[idProduk] = produk;
    }

    setState(() {
      logDeletedProducts = deleted;
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
                    Judul(title: 'Riwayat Produk'),
                    const SizedBox(height: 10),
                    if (isLoading)
                      Center(child: CircularProgressIndicator(color: Color(0xFF544C2A),))
                    else if (logDeletedProducts.isEmpty)
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
                        itemCount: logDeletedProducts.length,
                        itemBuilder: (_, index) {
                          final dataLog = logDeletedProducts[index];
                          final produk = produkData[dataLog['id_produk']];

                          if (produk == null) {
                            return Text('Produk tidak ditemukan');
                          }

                          return kontenbesar(context, dataLog, produk);
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

  Widget kontenbesar(BuildContext context, log, ProductModel produk ) {
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
                  produk.gender,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  produk.kategori.nama,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Rp ${produk.harga}',
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
                          _buildDetailRow('Gender', produk.gender),
                          _buildDetailRow('Kategori', produk.kategori.nama),
                          _buildDetailRow('Harga', 'Rp ${produk.harga}'),
                          _buildDetailRow('Deskripsi', produk.deskripsi),
                          _buildDetailRow('Alasan', log['alasan']),
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

}