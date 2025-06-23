class CategoriesModel {
  final String kid;
  final String nama;

  CategoriesModel({
    required this.kid,
    required this.nama
  });

  factory CategoriesModel.fromMap(Map<String, dynamic> data, String kid) {
    return CategoriesModel(
      kid: kid,
      nama: data['nama'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
    };
  }
}
