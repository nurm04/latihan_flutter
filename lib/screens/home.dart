import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lemari_lama/models/users.dart';
import 'package:lemari_lama/screens/pages/formProdukPage.dart';
import 'package:lemari_lama/screens/pages/profil/profilPage.dart';
import 'package:lemari_lama/screens/pages/reportPage.dart';
import 'package:lemari_lama/services/auth.dart';

import 'package:lemari_lama/screens/pages/homePage.dart';
import 'package:lemari_lama/screens/pages/dataUserPage.dart';
import 'package:lemari_lama/screens/pages/riwayatProdukPage.dart';



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  UserModel? _userData;

  int _selectedIndex = 0;

  void initState() {
    super.initState();
    _loadUserData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      UserModel? _userModel = await _authService.getUserData(user.uid);
      setState(() {
        _userData = _userModel;
      });
    }
  }
  

  signOut(context) async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actionsPadding: EdgeInsets.only(left: 10, right: 10),
        title:  Text(
          'Lemari Lama',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Color(0xFF544C2A),
         actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Colors.white,
            onSelected: (value) {
              if (value == 1) {
                Navigator.pushNamed(context, '/favorit');
              } else if (value == 2) {
                signOut(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<int>(
                enabled: false,
                child: Text(
                  'Halo, ${_userData?.nama}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text("Favorit"),
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _getSelectedPage(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF544C2A),
          unselectedItemColor: Color(0xFFB5AA7E),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _userData!.role == "admin"
          ? const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Riwayat Produk',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Komentar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Data User',
              ),
            ]
          : const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Tambah Produk',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil'
              ),
            ],
        ),
    );
  }

  Widget _getSelectedPage() {
    if (_userData?.role == 'admin') {
      switch (_selectedIndex) {
        case 0:
          return HomePage();
        case 1:
          return Riwayatprodukpage();
        case 2:
          return Reportpage();
        case 3:
          return DataUserPage();
        default:
          return const Center(child: Text('Halaman tidak ditemukan'));
      }
    } else {
      // untuk role 'user'
      switch (_selectedIndex) {
        case 0:
          return HomePage();
        case 1:
          return FormProdukPage(isUpdate: false);
        case 2:
          return ProfilPage();
        default:
          return const Center(child: Text('Halaman tidak ditemukan'));
      }
    }
  }
}
