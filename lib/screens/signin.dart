import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lemari_lama/component/CustomFormField.dart';
import 'package:lemari_lama/services/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';

  _signin(context) async {
    try {
      final user = await _authService.signIn(_email, _password);
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);

        if (userData != null && userData.is_blocked) {
          await _authService.signOut();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Akun Diblokir'),
              content: Text('Akun Anda telah diblokir oleh admin.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                )
              ],
            ),
          );
          return;
        }

        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Login Gagal'),
          content: Text(e.message ?? 'Terjadi kesalahan saat login'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 70.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Text(
              "Sign In",
              style: TextStyle(
                color: Colors.white,
                fontSize: 35.0,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 40.0,),
            Expanded (
              child: Container(
                padding: EdgeInsets.only(top: 50, left: 20, right: 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email
                        CustomFormField(
                          label: "Email",
                          icon: Icon(Icons.email, color: Color(0xFFB5AA7E)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value!,
                        ),
                        // Password
                        CustomFormField(
                          label: "Password",
                          hash: true,
                          icon: Icon(Icons.password, color: Color(0xFFB5AA7E)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            return null;
                          },
                          onSaved: (value) => _password = value!,
                        ),
                        SizedBox(height: 20.0,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF544C2A),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(MediaQuery.of(context).size.width, 0),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _signin(context);
                            }
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.0,),
                              Text(
                                "Don't have account?",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/signup'),
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 4, 72, 129),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                            ],
                          )
                      ],)
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}