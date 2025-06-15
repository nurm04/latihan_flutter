// ignore_for_file: unnecessary_null_comparison
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:lemari_lama/component/CustomDropdown.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lemari_lama/helper/img_helper.dart';

import 'package:lemari_lama/component/CustomFormField.dart';
import 'package:lemari_lama/component/Judul.dart';

import 'package:lemari_lama/models/users.dart';
import 'package:lemari_lama/models/categories.dart';
import 'package:lemari_lama/models/products.dart';

import 'package:lemari_lama/services/auth.dart';
import 'package:lemari_lama/services/kategori.dart';
import 'package:lemari_lama/services/produk.dart';

class FormProdukPage extends StatefulWidget {
  final String id;
  final bool isUpdate;

  const FormProdukPage({super.key, required this.isUpdate, this.id = ""});

  @override
  State<FormProdukPage> createState() => _FormProdukPageState();
}

class _FormProdukPageState extends State<FormProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  File? _image;
  CategoriesModel? _kategori;
  Position? _currentPosition;
  double latitude = 0;
  double longitude = 0;
  String imgUrl = "";

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await _loadKategori();
    await _loadUserData();
    if (widget.isUpdate) {
      await _loadProduct();
    }

    setState(() {
      _isLoading = false;
    });
  }

  final List<String> genderPakaian= [
    'Pria',
    'Wanita',
    'Unisex',
  ];

  // User
  final user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  UserModel? _userData;

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      UserModel? _userModel = await _authService.getUserData(user.uid);
      setState(() {
        _userData = _userModel;
      });
    }
  }

  // Kategori
  final KategoriService _kategoriService = KategoriService();
  List<CategoriesModel> _kategoriList = [];

  Future<void> _loadKategori() async {
    try {
      final kategoriList = await _kategoriService.getAllKategori();
      setState(() {
        _kategoriList = kategoriList;
      });
    } catch (e) {
      print('Error loading kategori: $e');
    }
  }

  // Image
  final ImagePicker picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    bool permissionGranted = false;
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      if (Platform.isAndroid) {
        permission = Permission.storage;
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.request();
    permissionGranted = status.isGranted;

    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Izin diperlukan untuk mengakses gambar.")),
      );
      return;
    }

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Gambar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Location
  Future<void> getCurrentLocation(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Layanan lokasi tidak aktif. Aktifkan GPS terlebih dahulu.")),
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Izin lokasi diperlukan.")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Izin lokasi ditolak permanen. Ubah lewat pengaturan.")),
        );
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String fullAddress = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";

        setState(() {
          _alamatController.text = fullAddress;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alamat: $fullAddress")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mendapatkan alamat.")),
        );
      }

    } on PlatformException catch (e) {
      debugPrint("PlatformException: ${e.code} | ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi error platform: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendapatkan lokasi: $e")),
      );
    }
  }

  // Product
  final _productService = ProductService();
  ProductModel? _produk;

  Future<void> _loadProduct() async {
    try {
      _produk = await _productService.getProduct(widget.id);
      if (_produk != null) {
        setState(() {
          _namaController.text = _produk!.nama;
          _hargaController.text = _produk!.harga.toString();
          _kategori = _kategoriList.firstWhere((k) => k.nama == _produk!.kategori.nama);
          _genderController.text = _produk!.gender;
          _deskripsiController.text = _produk!.deskripsi;
          _alamatController.text = _produk!.alamat;

          List<String> splitKoordinat = _produk!.lokasi.split(',');
          latitude = double.parse(splitKoordinat[0]);
          longitude = double.parse(splitKoordinat[1]);
          imgUrl = _produk!.gambar;
        });
      }
    } catch (e) {
      debugPrint("Error loading product: $e");
    }
  }
  
  saveProduk(context) async {
    if (_kategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategori belum dipilih.')),
      );
      return;
    }

    if (_genderController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gender produk belum dipilih.')),
      );
      return;
    }

    var lokasi = "";
    if (widget.isUpdate) {
      if (_currentPosition != null) {
        lokasi = "${_currentPosition?.latitude},${_currentPosition?.longitude}";
      } else {
        lokasi = "${latitude},${longitude}";
      }
    } else {
      if (_currentPosition == null || _alamatController == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lokasi belum diambil.')),
        );
        return;
      }
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );
      
      final imageFile;
      final cloudinary;
      final imageUrl;
      if (imgUrl == "") {
        if (_image == null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload gambar dulu')),
          );
          return;
        }
        imageFile = File(_image!.path);
        cloudinary = CloudinaryService();
        imageUrl = await cloudinary.uploadImageToCloudinary(imageFile);
      } else {
        if (_image != null) {
          imageFile = File(_image!.path);
          cloudinary = CloudinaryService();
          imgUrl = await cloudinary.uploadImageToCloudinary(imageFile);
        }
        imageUrl = imgUrl;
      }

      if (widget.isUpdate) {
        await _productService.updateProduct(widget.id, {
          'nama': _namaController.text,
          'harga': int.parse(_hargaController.text),
          'kategori': {
            'kid': _kategori?.kid,
            'nama': _kategori?.nama,
          },
          'gender': _genderController.text,
          'deskripsi': _deskripsiController.text,
          'pemilik': {
            'uid': _userData?.uid,
            'nama': _userData?.nama,
            'email': _userData?.email,
            'nohp': _userData?.nohp,
          },
          'lokasi': lokasi,
          'alamat': _alamatController.text,
          'gambar': imageUrl,
          'is_active': true
        });
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Success'),
            content: Text('Produk berhasil diubah.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, 'updated');
                },
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
      } else {
        await _productService.addProduct(ProductModel(
          pid: '',
          nama: _namaController.text,
          harga: int.parse(_hargaController.text),
          kategori: _kategori!,
          gender: _genderController.text,
          deskripsi: _deskripsiController.text,
          pemilik: _userData!,
          lokasi: "${_currentPosition?.latitude},${_currentPosition?.longitude}",
          alamat: _alamatController.text,
          gambar: imageUrl,
          is_active: true
        ));
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Success'),
            content: Text('Produk berhasil dibuat.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/kategori/${_kategori!.nama}');
                },
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
    if (_userData == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF544C2A),)),
      );
    }
    return Scaffold(
      appBar: !widget.isUpdate
      ? null
      : AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Judul(title: "Form Jual Pakaian"),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    _showImageSourceOptions();
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFB5AA7E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _image != null
                    ? SizedBox(
                      width: double.infinity,
                      child: Image.file( _image!, fit: BoxFit.contain),
                    )
                    : imgUrl != ""
                    ? SizedBox(
                      width: double.infinity,
                      child: Image.network( imgUrl, fit: BoxFit.contain),
                    )
                    : SizedBox(
                      height: 250,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: Colors.white),
                          SizedBox(height: 10),
                          Text('Upload Image', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    )
                  ),
                ),
                SizedBox(height: 10),
                CustomFormField(
                  label: "Nama Produk",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Produk tidak boleh kosong';
                    }
                    return null;
                  },
                  controller: _namaController,
                  onSaved: (value) => _namaController.text = value!,
                ),
                CustomFormField(
                  label: "Harga Produk",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga Produk tidak boleh kosong';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Harga Produk harus angka';
                    }
                    return null;
                  },
                  controller: _hargaController,
                  onSaved: (value) => _hargaController.text = value!,
                ),
                CustomDropdown<CategoriesModel>(
                  label: "Kategori Pakaian",
                  items: _kategoriList.map((kategori) {
                    return DropdownMenuItem<CategoriesModel>(
                      value: kategori,
                      child: Text(kategori.nama),
                    );
                  }).toList(),
                  value: _kategori,
                  onChanged: (value) => setState(() => _kategori = value),
                  validator: (value) {
                    if (value == null) {
                      return 'Kategori harus dipilih';
                    }
                    return null;
                  },
                  isUpdate: widget.isUpdate,
                ),
                CustomDropdown<String>(
                  label: "Gender",
                  items: genderPakaian.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  value: _genderController.text.isEmpty ? null : _genderController.text,
                  onChanged: (value) => setState(() => _genderController.text = value ?? ""),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis kelamin harus dipilih';
                    }
                    return null;
                  },
                  isUpdate: widget.isUpdate,
                ),
                CustomFormField(
                  label: "Deskripsi",
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                  controller: _deskripsiController,
                  onSaved: (value) => _deskripsiController.text = value!,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(
                    "Lokasi :",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF544C2A),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    getCurrentLocation(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFB5AA7E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 250,
                    child: _currentPosition != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('currentLocation'),
                            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          )
                        },
                      ),
                    )
                    : latitude == 0 && longitude == 0
                    ? SizedBox(
                      height: 250,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, size: 50, color: Colors.white),
                          SizedBox(height: 10),
                          Text('Ambil Lokasi Saat Ini', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude, longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('currentLocation'),
                            position: LatLng(latitude, longitude),
                          )
                        },
                      ),
                    ),
                  ),
                ),
                CustomFormField(
                  label: "Alamat",
                  enabled: false,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat tidak boleh kosong';
                    }
                    return null;
                  },
                  controller: _alamatController,
                  onSaved: (value) => _alamatController.text = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      saveProduk(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544C2A),
                  ),
                  child: Text('Simpan', style: TextStyle(color: Colors.white),),
                ),
                TextButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                    setState(() {
                      imgUrl = "";
                      _image = null;
                      latitude = 0; 
                      longitude = 0;
                      _currentPosition = null;


                      _namaController.text = '';
                      _hargaController.text = '';
                      _kategori = null;
                      _genderController.text = '';
                      _deskripsiController.text = '';
                      _alamatController.text = '';
                    });
                  },
                  child: Text('Reset', style: TextStyle(color: Color(0xFF544C2A)),),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}