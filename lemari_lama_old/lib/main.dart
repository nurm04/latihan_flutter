import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:lemari_lama/screens/signin.dart';
import 'package:lemari_lama/screens/signup.dart';
import 'package:lemari_lama/screens/home.dart';
import 'package:lemari_lama/screens/kategori.dart';
import 'package:lemari_lama/screens/favoritProduk.dart';
import 'package:lemari_lama/screens/pages/formProdukPage.dart';
import 'package:lemari_lama/screens/splashScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Color(0xFF544C2A),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF544C2A),
          selectionColor: Color(0xFFAAA06D),
          selectionHandleColor: Color(0xFF544C2A),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);
        Widget page;

        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        } else if (settings.name == '/signin') {
          page = const SignIn();
        } else if (settings.name == '/signup') {
          page = const SignUp();
        } else if (settings.name == '/home') {
          page = const Home();
        } else if (settings.name == '/favorit') {
          page = const Favoritproduk();
        } else if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'update-product') {
          final id = uri.pathSegments[1];
          page = FormProdukPage(isUpdate: true, id: id);
        } else if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'kategori') {
          final kategoriNama = uri.pathSegments[1];
          page = KategoriPage(kategoriNama: kategoriNama);
        } else {
          page = const Scaffold(
            body: Center(child: Text('404 Not Found')),
          );
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }
}