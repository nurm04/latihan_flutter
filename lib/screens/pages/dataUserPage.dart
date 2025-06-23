import 'package:flutter/material.dart';
import 'package:lemari_lama/component/Judul.dart';
import 'package:lemari_lama/models/users.dart';
import 'package:lemari_lama/services/user.dart';


class DataUserPage extends StatefulWidget {
  const DataUserPage({super.key});

  @override
  State<DataUserPage> createState() => _DataUserPageState();
}

class _DataUserPageState extends State<DataUserPage> {
  final UserService _userService = UserService(); 
  List<UserModel> _userData = [];
  bool _isLoading = true;

  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser () async {
    try {
      final users = await _userService.getAllUser();
      final filtered = users.where((u) => 
        u.role == "user"
      ).toList();

      setState(() {
        _userData = filtered;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> blockUser(uid) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: Color(0xFF544C2A))),
    );
    try {
      await _userService.updateUser(uid, {
        'is_blocked': true
      });
      Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk berhasil dilaporkan dan disembunyikan.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      await loadUser();
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Gagal'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Iya', 
                style: TextStyle(
                  color: Color(0xFF544C2A)
                )
              ),
            )
          ],
        ),
      );
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
                    Judul(title: 'Data User'),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      Center(child: CircularProgressIndicator(color: Color(0xFF544C2A),))
                    else if (_userData.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text('Tidak ada data.'),
                      ),
                    )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _userData.length,
                        itemBuilder: (_, index) {
                          final dataUser = _userData[index];
                          return kontenbesar(context, dataUser);
                        },
                      ),  
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget kontenbesar(BuildContext context, UserModel user) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SizedBox(width: 7),
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF544C2A),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF544C2A),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nama,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF544C2A)
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  user.nohp,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  user.is_blocked ? 'Di Block' : 'Aktif',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(Icons.block, color: Color(0xFF544C2A)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      titlePadding: EdgeInsets.only(top: 16, left: 20, right: 8),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          ),
                        ],
                      ),
                      content: Text("Yakin ingin block user ini?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            blockUser(user.uid);
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Iya', 
                            style: TextStyle(
                              color: Color(0xFF544C2A)
                            )
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}