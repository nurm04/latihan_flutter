class LogDeleteProductModel {
  final String id;
  final String id_produk;
  final String alasan;

  LogDeleteProductModel({
    required this.id,
    required this.id_produk,
    required this.alasan,
  });

  factory LogDeleteProductModel.fromMap(Map<String, dynamic> data) {
    return LogDeleteProductModel(
      id: data['id'] ?? '',
      id_produk: data['id_produk'] ?? '',
      alasan: data['alasan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_produk': id_produk,
      'alasan': alasan,
    };
  }
}
