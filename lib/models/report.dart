class ReportModel {
  final String id;
  final String id_pelapor;
  final String id_produk;
  final String alasan;

  ReportModel({
    required this.id,
    required this.id_pelapor,
    required this.id_produk,
    required this.alasan,
  });

  factory ReportModel.fromMap(Map<String, dynamic> data) {
    return ReportModel(
      id: data['id'] ?? '',
      id_pelapor: data['id_pelapor'] ?? '',
      id_produk: data['id_produk'] ?? '',
      alasan: data['alasan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_pelapor': id_pelapor,
      'id_produk': id_produk,
      'alasan': alasan,
    };
  }
}
