class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String nohp;
  final String role;
  final bool is_blocked;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.nohp,
    required this.role,
    required this.is_blocked,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      nohp: data['nohp'] ?? '',
      role: data['role'] ?? '',
      is_blocked: data['is_blocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'nohp': nohp,
      'role': role,
      'is_blocked': is_blocked
    };
  }
}
