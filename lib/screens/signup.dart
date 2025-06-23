import 'package:firebase_auth/firebase_auth.dart';
import 'package:lemari_lama/component/CustomFormField.dart';

import '../services/auth.dart';
import '../models/users.dart';

import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  String _nama = '';
  String _email = '';
  String _password = '';
  String _nohp = '';
  bool hashPassword = true;

  signup(context) async {
    try {
      final userModel = UserModel(
        uid: '',
        nama: _nama,
        email: _email,
        nohp: _nohp,
        role: "user",
        is_blocked: false,
      );

      await _authService.signUp(userModel, _password);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Success'),
          content: Text('Akun berhasil dibuat.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signin'),
              child: Text('OK'),
            )
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Sign Up Failed'),
          content: Text(e.code),
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
              "Create Your Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 35.0,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 40.0,),
            Expanded(
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
                        CustomFormField(
                          label: "Nama",
                          icon: Icon(Icons.person_outline, color: Color(0xFFB5AA7E)),
                          validator: (value) {
                            if (value == null  || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                          onSaved: (value) => _nama = value!,
                        ),
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
                        CustomFormField(
                          label: 'Enter No Handphone',
                          icon: Icon(Icons.numbers_outlined, color: Color(0xFFB5AA7E)),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null  || value.isEmpty) {
                              return 'No Handphone tidak boleh kosong';
                            } 
                            if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                              return 'No Handphone harus 12 digit';
                            }
                            return null;
                          },
                          onSaved: (value) => _nohp = value!,
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
                              signup(context);
                            }
                          },
                          child: const Text(
                            'Sign Up',
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
                                "Already have an account?",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/signin'),
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 4, 72, 129),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                            ],
                          )
                      ],),
                      SizedBox(height: 40.0,),
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