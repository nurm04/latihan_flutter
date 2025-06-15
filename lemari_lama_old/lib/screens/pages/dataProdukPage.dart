// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lemari_lama/component/Judul.dart';
import 'package:lemari_lama/component/CardProduct.dart';

import 'package:lemari_lama/models/products.dart';
import 'package:lemari_lama/services/produk.dart';

import 'package:lemari_lama/models/users.dart';
import 'package:lemari_lama/services/auth.dart';

class DataProdukPage extends StatefulWidget {
  const DataProdukPage({super.key});

  @override
  State<DataProdukPage> createState() => _DataProdukPageState();
}

class _DataProdukPageState extends State<DataProdukPage> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  final user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  UserModel? _userData;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await loadUserData();
    await loadProducts();
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
        p.pemilik.uid == _userData?.uid
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
                    Judul(title: "Produk anda"),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      Center(child: CircularProgressIndicator(color: Color(0xFF544C2A),))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _products.length,
                        itemBuilder: (conte, index) {
                          final product = _products[index];

                          if (product == null) {
                            return Text('Produk tidak ditemukan');
                          }

                          return CardProduk(
                            product: product,
                            parentContext: context,
                            userData: _userData,
                            onRefresh: loadProducts,
                            isUpdate: true,
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
    );
  }
}
