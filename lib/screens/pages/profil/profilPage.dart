// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lemari_lama/component/CardProduct.dart';

import 'package:lemari_lama/models/products.dart';
import 'package:lemari_lama/services/produk.dart';

import 'package:lemari_lama/models/users.dart';
import 'package:lemari_lama/services/auth.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  final user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  UserModel? _userData;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      debugPrint("Jumlah produk milik user ${_userData?.uid}: ${filtered.length}");
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

  List<ProductModel> get semuaProduk => _products;
  List<ProductModel> get produkTerjual =>
    _products;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        body: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFB5AA7E),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("nama", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF544C2A))),
                        Text("email@gmail.com", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF544C2A))),
                        Text("081234567890", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF544C2A))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_square, color: Color(0xFF544C2A)),
                    onPressed: () {
                      Navigator.pushNamed(context, '/profil-edit');
                    },
                  ),
                ],
              ),
            ),

            // Tab bar
            const TabBar(
              indicatorColor: Color(0xFF544C2A),
              labelColor: Color(0xFF544C2A),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.list), text: "Semua Produk"),
                Tab(icon: Icon(Icons.check_circle_outline), text: "Terjual"),
              ],
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(semuaProduk),
                  _buildList(produkTerjual),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<ProductModel> produkList) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF544C2A)));
    }

    if (produkList.isEmpty) {
      return const Center(child: Text("Tidak ada produk"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: produkList.length,
      itemBuilder: (context, index) {
        final product = produkList[index];
        return CardProduk(
          product: product,
          parentContext: context,
          userData: _userData,
          onRefresh: loadProducts,
          isUpdate: true,
        );
      },
    );
  }
}
