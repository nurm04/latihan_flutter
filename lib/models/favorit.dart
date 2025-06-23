class FavoritModel {
  final String id;
  final String id_user;
  final String id_produk;

  FavoritModel({
    required this.id,
    required this.id_user,
    required this.id_produk
  });

  factory FavoritModel.fromMap(Map<String, dynamic> data) {
    return FavoritModel(
      id: data['id'] ?? '',
      id_user: data['id_user'] ?? '',
      id_produk: data['id_produk'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_user': id_user,
      'id_produk': id_produk,
    };
  }
}
