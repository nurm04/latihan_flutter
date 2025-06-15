import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lemari_lama/component/Judul.dart';
import 'package:lemari_lama/component/CardProduct.dart';

import 'package:lemari_lama/helper/db_helper.dart';

import 'package:lemari_lama/models/products.dart';
import 'package:lemari_lama/models/users.dart';

import 'package:lemari_lama/services/auth.dart';
import 'package:lemari_lama/services/produk.dart';

class Favoritproduk extends StatefulWidget {
  const Favoritproduk({super.key});

  @override
  State<Favoritproduk> createState() => _FavoritprodukState();
}

class _FavoritprodukState extends State<Favoritproduk> {
  List<Map<String, dynamic>> logFavoritProducts = [];
  Map<String, ProductModel?> produkData = {};
  final _produkService = ProductService();
  bool isLoading = true;

  void initState() {
    super.initState();
    initializeData();
  }
  
  Future<void> initializeData() async {
    await loadUserData();
    await loadProducts();
  }

  final user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  UserModel? _userData;

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      UserModel? _userModel = await _authService.getUserData(user.uid);
      setState(() {
        _userData = _userModel;
      });
    }
  }

  Future<void> loadProducts() async {
    final fav = await DBHelper.getAllCollectionProductsLogByUser(_userData!.uid);
    Map<String, ProductModel?> produkMap = {};

    for (var log in fav) {
      final idProduk = log['id_produk'];
      if (idProduk == null) continue;
      final produk = await _produkService.getProduct(idProduk);
      produkMap[idProduk] = produk;
    }

    setState(() {
      logFavoritProducts = fav;
      produkData = produkMap;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actionsPadding: EdgeInsets.only(left: 10, right: 10),
        title:  Text(
          'Lemari Lama',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Color(0xFF544C2A),
      ),
      body: Scaffold(
        backgroundColor: Color.fromARGB(255, 240, 240, 240),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Judul(title: 'Koleksi Produk'),
                      SizedBox(height: 10),
                      if (isLoading)
                        Center(child: CircularProgressIndicator(color: Color(0xFF544C2A)))
                      else if (logFavoritProducts.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text('Tidak ada data.'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: logFavoritProducts.length,
                          itemBuilder: (conte, index) {
                            final dataLog = logFavoritProducts[index];
                            final product = produkData[dataLog['id_produk']];

                            if (product == null) {
                              return Text('Produk tidak ditemukan');
                            }

                            return CardProduk(
                              product: product,
                              parentContext: context,
                              userData: _userData,
                              onRefresh: loadProducts,
                            );
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
      ),
    );
  }
}