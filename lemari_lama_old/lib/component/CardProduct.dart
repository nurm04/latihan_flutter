import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lemari_lama/helper/db_helper.dart';

import 'package:lemari_lama/models/products.dart';
import 'package:lemari_lama/services/produk.dart';

import 'package:lemari_lama/models/users.dart';

class CardProduk extends StatelessWidget {
  final ProductModel product;
  final BuildContext parentContext;
  final UserModel? userData;
  final VoidCallback? onRefresh;
  final bool isUpdate;

  CardProduk({
    Key? key,
    required this.product,
    required this.parentContext,
    this.userData,
    this.onRefresh,
    this.isUpdate = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        _showModalBottomSheet(context, product);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    _showImagePopup(context, product.gambar);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      product.gambar,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFB5AA7E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.gender,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFB5AA7E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.kategori.nama,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 18, color: Color(0xFF544C2A)),
                      SizedBox(width: 6),
                      Text(
                        product.pemilik.nama,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.nama,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rp ${product.harga}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB5AA7E),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.deskripsi,
                    style: TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 18, color: Color(0xFF544C2A)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _cleanAlamat(product.alamat),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  !isUpdate
                  ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB5AA7E),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        keWhatsApp(product.pemilik.nohp, context, product);
                      },
                      icon: Icon(Icons.chat, color: Colors.white),
                      label: Text(
                        'Chat Pemilik',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  )
                  : Row(
                    children: [
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
                                      deleteProduct(product.pid);
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
                      SizedBox(width: 4),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB5AA7E),
                        ),
                        onPressed: () async {
                          final result = await Navigator.pushNamed(context, '/update-product/${product.pid}');
                          if (result == 'updated') {
                            if (onRefresh != null) {
                              onRefresh!();
                            }
                          }
                        },
                        child: Icon(Icons.edit_square, color: Colors.white,),
                      ),
                    ]
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(color: Color(0xFF544C2A)),
            ),
          ),
        ),
      ),
    );
  }


  Future<void> deleteProduct(pid) async {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: Color(0xFF544C2A))),
    );
    try {
      final ProductService _productService = ProductService();
      await _productService.deleteProduct(pid);
      Navigator.pop(parentContext);
        ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text('Produk berhasil dilaporkan dan disembunyikan.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      if (onRefresh != null) {
        onRefresh!();
      }
    } catch (e) {
      Navigator.pop(parentContext);
      showDialog(
        context: parentContext,
        builder: (_) => AlertDialog(
          title: Text('Gagal'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(parentContext),
              child: Text(
                'Iya', 
                style: TextStyle(
                  color: Color(0xFF544C2A)
                )
              ),
            )
          ],
        ),
      );
    }
  }

  String _cleanAlamat(String alamat) {
    if (alamat.contains(',')) {
      alamat = alamat.substring(alamat.indexOf(',') + 1).trim();
    }
    alamat = alamat.replaceAll(RegExp(r'\b\d{5}\b$'), '').trim();
    return alamat;
  }

  Future<void> keWhatsApp(String nomorHp, context, ProductModel product) async {
    if (nomorHp.startsWith('0')) {
      nomorHp = '+62' + nomorHp.substring(1);
    }

    final hargaFormat = NumberFormat.decimalPattern('id_ID').format(product.harga);

    String prePesan = '''
    Halo, saya melihat produk ini di aplikasi *Lemari Lama* dan saya tertarik.

    📦 *Nama Produk:* ${product.nama}
    📁 *Kategori:* ${product.kategori.nama}
    👤 *Pemilik:* ${product.pemilik.nama}
    💰 *Harga:* Rp $hargaFormat
    📝 *Deskripsi:* ${product.deskripsi}

    Apakah produk ini masih tersedia?
    ''';
    String pesan = Uri.encodeComponent(prePesan);
    final whatsappUrl = Uri.parse("https://wa.me/${nomorHp.replaceAll('+', '')}?text=$pesan");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Gagal'),
          content: Text('Tidak dapat membuka WhatsApp'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Iya', 
                style: TextStyle(
                  color: Color(0xFF544C2A)
                )
              ),
            )
          ],
        ),
      );
    }
  }

  void _showModalBottomSheet(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: userData!.role == "user"
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text(
                    ModalRoute.of(parentContext)?.settings.name == '/favorit'
                      ? 'Hapus dari koleksi'
                      : 'Simpan produk ke koleksi',
                  ),
                  onTap: () {
                    Navigator.of(parentContext).pop();
                    Future.delayed(Duration(milliseconds: 100), () {
                      final currentRoute = ModalRoute.of(parentContext)?.settings.name;
                      favProduct(product, currentRoute == '/favorit' ? false : true);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.flag),
                  title: Text('Laporkan'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Future.delayed(Duration(milliseconds: 100), () {
                      _showLaporkanDialog(product);
                    });
                  },
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Hapus data'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Future.delayed(Duration(milliseconds: 100), () {
                      _showLaporkanDialog(product);
                    });
                  },
                )
              ],
            ),
        );
      },
    );
  }
  
  void _showLaporkanDialog(ProductModel product) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.only(top: 16, left: 20, right: 8),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Laporkan', style: TextStyle(fontWeight: FontWeight.bold)),
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
              ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text('Penipuan / Produk tidak sesuai'),
                onTap: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  await reportProduct('Foto tidak pantas', product);
                },
              ),
              ListTile(
                leading: Icon(Icons.image_not_supported, color: Colors.red),
                title: Text('Foto tidak pantas'),
                onTap: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  await reportProduct('Foto tidak pantas', product);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> favProduct(ProductModel product, bool save) async {
    if (save) {
      await DBHelper.insertLogCollectionProduct({
        'id_user': userData?.uid,
        'id_produk': product.pid,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await DBHelper.deleteLogCollectionProduct(userData!.uid, product.pid);
    }

    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text(
          save ? 'Produk berhasil disimpan' : 'Produk tidak simpan',
          style: TextStyle(
            color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
        duration: Duration(seconds: 3),
      ),
    );

    if (onRefresh != null && !save) {
      onRefresh!();
    }
  }

  Future<int> reportProduct(text, ProductModel product) async {
    debugPrint("insert reportProduk dimulai");
    int result;
    if (userData?.role == "admin") {
      result = await DBHelper.insertLogDeleteProduct({
        'id_produk': product.pid,
        'alasan': text,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      final productService = ProductService();
      await productService.updateProduct(product.pid, {
        'is_active': false,
      });
    } else {
      result = await DBHelper.insertLogReportProduct({
        'id_pelapor': userData?.uid,
        'id_produk': product.pid,
        'alasan': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    debugPrint("insert reportProduk selesai");

    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text('Produk berhasil dilaporkan'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 3),
      ),
    );

    if (onRefresh != null) {
      onRefresh!();
    }

    return result;
  }
}
