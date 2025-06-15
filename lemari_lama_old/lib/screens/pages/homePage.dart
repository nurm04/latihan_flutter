// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:lemari_lama/component/Judul.dart';
import 'package:lemari_lama/component/CardProduct.dart';

import 'package:lemari_lama/models/products.dart';
import 'package:lemari_lama/services/produk.dart';

import 'package:lemari_lama/models/users.dart';
import 'package:lemari_lama/services/auth.dart';

import 'package:lemari_lama/services/kategori.dart';
import 'package:lemari_lama/models/categories.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final KategoriService _kategoriService = KategoriService();
  List<CategoriesModel> _kategoriList = [];

  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];

  final user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  UserModel? _userData;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadKategori();
    loadProducts();
    loadUserData();
  }

  Future<void> loadKategori() async {
    try {
      final kategoriList = await _kategoriService.getAllKategori();
      setState(() {
        _kategoriList = kategoriList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading kategori: $e');
    }
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
                    Judul(title: 'Kategori'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _kategoriList.length,
                        itemBuilder: (context, index) {
                          final kategori = _kategoriList[index];
                          return kat(
                            judulKat: kategori.nama,
                            context: context
                          );
                        },
                      ),
                    ),
                    Judul(title: 'Terbaru'),
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

  Widget kat({
    required String judulKat,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        final slug = judulKat.toLowerCase().replaceAll(' ', '-');
        Navigator.pushNamed(context, '/kategori/$slug');
      },
      child: Container(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF544C2A),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/bg1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              judulKat,
              style: TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
    );
  }
}
