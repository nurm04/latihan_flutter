import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lemari_lama/models/categories.dart';
import 'package:lemari_lama/models/products.dart';
import 'package:lemari_lama/models/users.dart';
import 'package:lemari_lama/services/kategori.dart';
import 'package:lemari_lama/services/user.dart';

class ProductService {
  final CollectionReference _products = FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(ProductModel product) async {
    try {
      final docRef = _products.doc();
      final productWithId = ProductModel(
        pid: docRef.id,
        nama: product.nama,
        harga: product.harga,
        kategori: product.kategori,
        gender: product.gender,
        deskripsi: product.deskripsi,
        pemilik: product.pemilik,
        lokasi: product.lokasi,
        alamat: product.alamat,
        gambar: product.gambar,
        is_active: product.is_active,
      );

      await docRef.set(productWithId.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel?> getProduct(String pid) async {
    try {
      DocumentSnapshot snapshot = await _products.doc(pid).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final KategoriService _kategoriService = KategoriService();
        CategoriesModel? kategoriModel = await _kategoriService.getKategori(data['kategori']);
        final UserService _userService = UserService();
        UserModel? userModel = await _userService.getUser(data['pemilik']);

        return ProductModel.fromMapWithResolvedData(
          data: data,
          pid: snapshot.id,
          kategori: kategoriModel!,
          pemilik: userModel!,
        );
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Future<List<ProductModel>> getAllProducts() async {
  //   try {
  //     QuerySnapshot snapshot = await _products.get();
  //     return snapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       return ProductModel.fromMap(data, doc.id);
  //     }).toList();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      QuerySnapshot snapshot = await _products.get();
      List<ProductModel> products = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final KategoriService _kategoriService = KategoriService();
        CategoriesModel? kategoriModel = await _kategoriService.getKategori(data['kategori']);
        final UserService _userService = UserService();
        UserModel? userModel = await _userService.getUser(data['pemilik']);

        if (kategoriModel != null && userModel != null) {
          final product = ProductModel.fromMapWithResolvedData(
            data: data,
            pid: doc.id,
            kategori: kategoriModel,
            pemilik: userModel,
          );
          products.add(product);
        }
      }

      return products;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByKategori(String kategoriId) async {
    try {
      QuerySnapshot snapshot = await _products.where('kategori', isEqualTo: kategoriId).get();
      List<ProductModel> products = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final KategoriService _kategoriService = KategoriService();
        CategoriesModel? kategoriModel = await _kategoriService.getKategori(data['kategori']);
        final UserService _userService = UserService();
        UserModel? userModel = await _userService.getUser(data['pemilik']);

        if (kategoriModel != null && userModel != null) {
          final product = ProductModel.fromMapWithResolvedData(
            data: data,
            pid: doc.id,
            kategori: kategoriModel,
            pemilik: userModel,
          );
          products.add(product);
        }
      }

      return products;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String pid, Map<String, dynamic> data) async {
    try {
      await _products.doc(pid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String pid) async {
    try {
      await _products.doc(pid).delete();
    } catch (e) {
      rethrow;
    }
  }
}
