// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lemari_lama/component/Judul.dart';
import 'package:lemari_lama/component/CardProduct.dart';

import 'package:lemari_lama/models/products.dart';
import 'package:lemari_lama/services/produk.dart';

import 'package:lemari_lama/models/users.dart';
import 'package:lemari_lama/services/auth.dart';

class KategoriPage extends StatefulWidget {
  final String kategoriNama;

  const KategoriPage({super.key, required this.kategoriNama});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  final user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  UserModel? _userData;

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadUserData();
  }

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
    try {
      final products = await _productService.getAllProducts();
      final filtered = products.where((p) => 
        p.kategori.nama.toLowerCase() == widget.kategoriNama.toLowerCase() && 
        p.is_active == true &&
        p.pemilik.is_blocked == false
      ).toList();

      setState(() {
        _products = filtered;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, "/home");
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
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Judul(title: "Categories: ${widget.kategoriNama}"),
                      const SizedBox(height: 10),
                      if (_isLoading)
                        Center(child: CircularProgressIndicator(color: Color(0xFF544C2A)))
                      else if (_products.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              'Tidak ada Produk di kategori ini',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _products.length,
                          itemBuilder: (conte, index) {
                            final product = _products[index];
                            return CardProduk(
                              product: product,
                              parentContext: context,
                              userData: _userData,
                              onRefresh: loadProducts,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
