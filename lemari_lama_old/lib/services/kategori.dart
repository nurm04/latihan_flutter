import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lemari_lama/models/categories.dart';

class KategoriService {
  final CollectionReference _kategori = FirebaseFirestore.instance.collection('categories');

  Future<void> addKategori(CategoriesModel kategoriModel) async {
    try {
      await _kategori.doc(kategoriModel.kid).set(kategoriModel.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<CategoriesModel?> getKategori(String cari) async {
    try {
      DocumentSnapshot snapshot = await _kategori.doc(cari).get();
      if (snapshot.exists) {
        return CategoriesModel.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
      }

      QuerySnapshot querySnapshot = await _kategori.where('nama', isEqualTo: cari).get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return CategoriesModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }


  Future<List<CategoriesModel>> getAllKategori() async {
    try {
      QuerySnapshot snapshot = await _kategori.get();
      return snapshot.docs.map((doc) {
        return CategoriesModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }


  Future<void> updateKategori(String kid, Map<String, dynamic> data) async {
    try {
      await _kategori.doc(kid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteKategori(String kid) async {
    try {
      await _kategori.doc(kid).delete();
    } catch (e) {
      rethrow;
    }
  }
}
