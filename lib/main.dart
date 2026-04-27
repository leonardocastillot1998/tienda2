import 'dart:convert';

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kUsersKey = 'users';
const String kLoggedInKey = 'loggedIn';
const String kUsernameKey = 'username';
const String kProductsKey = 'products';
const String kPurchaseHistoryKey = 'purchaseHistory';
const String kProfileImageKey = 'profileImage';

Future<Map<String, Map<String, dynamic>>> _readUserRecords() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(kUsersKey);
  if (raw == null || raw.isEmpty) return {};
  try {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return data.map((key, value) {
      if (value is String) {
        return MapEntry(key, {'password': value, 'role': 'user'});
      }
      return MapEntry(key, Map<String, dynamic>.from(value as Map));
    });
  } catch (_) {
    return {};
  }
}

Future<void> _saveUserRecords(Map<String, Map<String, dynamic>> users) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(kUsersKey, jsonEncode(users));
}

String _getUserPassword(Map<String, dynamic>? record) {
  if (record == null) return '';
  return record['password']?.toString() ?? '';
}

String _getUserRole(Map<String, dynamic>? record) {
  if (record == null) return 'user';
  return record['role']?.toString() ?? 'user';
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tienda Puntos y Recompensas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, Map<String, dynamic>>> _readUsers() => _readUserRecords();

  Future<void> _saveUsers(Map<String, Map<String, dynamic>> users) =>
      _saveUserRecords(users);

  Future<void> _ensureDefaultUser() async {
    final users = await _readUsers();
    if (!users.containsKey('leonardo')) {
      users['leonardo'] = {'password': '1234', 'role': 'admin'};
      await _saveUserRecords(users);
    }
  }

  String _pointsKeyFor(String username) => 'puntos:$username';

  Future<void> _checkSavedSession() async {
    setState(() => _isLoading = true);

    await _ensureDefaultUser();

    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(kLoggedInKey) ?? false;
    final currentUser = prefs.getString(kUsernameKey) ?? '';

    if (loggedIn && currentUser.isNotEmpty) {
      final users = await _readUserRecords();
      final role = _getUserRole(users[currentUser]);
      final puntos = prefs.getInt(_pointsKeyFor(currentUser)) ?? 20;
      await prefs.setInt(_pointsKeyFor(currentUser), puntos);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            username: currentUser,
            puntos: puntos,
            isAdmin: role == 'admin',
          ),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _error = null;
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final users = await _readUserRecords();
    final record = users[username];
    final passwordStored = _getUserPassword(record);
    final isAdmin = _getUserRole(record) == 'admin';

    if (passwordStored == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kLoggedInKey, true);
      await prefs.setString(kUsernameKey, username);

      final puntaje = prefs.getInt(_pointsKeyFor(username)) ?? 20;
      await prefs.setInt(_pointsKeyFor(username), puntaje);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              HomePage(username: username, puntos: puntaje, isAdmin: isAdmin),
        ),
      );
    } else {
      setState(() {
        _error =
            'Usuario o contraseña inválidos. Crea cuenta o prueba leonardo / 1234';
      });
      setState(() => _isLoading = false);
    }
  }

  Future<void> _goToRegister() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
    if (!mounted) return;
    _checkSavedSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de sesión')),
      backgroundColor: Colors.lightBlue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 120,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.storefront,
                                size: 68,
                                color: Colors.blueAccent,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Usuario'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el usuario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa la contraseña';
                          }
                          if (value.length < 4) {
                            return 'La contraseña debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _login,
                        child: const SizedBox(
                          width: double.infinity,
                          child: Center(child: Text('Entrar')),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _goToRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const SizedBox(
                          width: double.infinity,
                          child: Center(child: Text('Crear cuenta')),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _newUserController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<Map<String, Map<String, dynamic>>> _readUsers() => _readUserRecords();

  Future<void> _saveUsers(Map<String, Map<String, dynamic>> users) =>
      _saveUserRecords(users);

  String _pointsKeyFor(String username) => 'puntos:$username';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final username = _newUserController.text.trim();
    final password = _newPassController.text;

    final users = await _readUsers();

    if (users.containsKey(username)) {
      setState(() {
        _error = 'El usuario ya existe. Elige otro nombre.';
        _isLoading = false;
      });
      return;
    }

    users[username] = {'password': password, 'role': 'user'};
    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKeyFor(username), 20);
    await prefs.setBool(kLoggedInKey, true);
    await prefs.setString(kUsernameKey, username);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            HomePage(username: username, puntos: 20, isAdmin: false),
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _newUserController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      backgroundColor: Colors.lightBlue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 120,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.storefront,
                                size: 68,
                                color: Colors.blueAccent,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _newUserController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de usuario',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el nombre de usuario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newPassController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa la contraseña';
                          }
                          if (value.length < 4) {
                            return 'La contraseña debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _register,
                        child: const SizedBox(
                          width: double.infinity,
                          child: Center(child: Text('Crear cuenta')),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class Product {
  String nombre;
  int puntos;
  String? image;
  Uint8List? imageBytes;

  Product({
    required this.nombre,
    required this.puntos,
    this.image,
    this.imageBytes,
  });
}

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _pointsController;
  late final TextEditingController _imageController;
  Uint8List? _pickedImage;
  String? _selectedImageName;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.nombre ?? '');
    _pointsController = TextEditingController(
      text: widget.product?.puntos.toString() ?? '',
    );
    _imageController = TextEditingController(text: widget.product?.image ?? '');
    _pickedImage = widget.product?.imageBytes;
    _selectedImageName =
        widget.product != null && widget.product!.imageBytes != null
        ? 'Imagen local cargada'
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pointsController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        withData: true,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return null;
      return result.files.first.bytes;
    } catch (_) {
      return null;
    }
  }

  String normalizeImagePath(String raw) {
    var path = raw.trim();
    if (path.toLowerCase().endsWith('.pmg')) {
      path = path.substring(0, path.length - 4) + '.png';
    }
    return path;
  }

  Future<void> _selectImage() async {
    final bytes = await _pickImage();
    if (bytes == null) {
      setState(() {
        _imageError = 'No se pudo cargar la imagen. Intenta otro archivo.';
      });
      return;
    }
    setState(() {
      _pickedImage = bytes;
      _selectedImageName = 'Imagen local seleccionada';
      _imageError = null;
      _imageController.text = _selectedImageName!;
    });
  }

  void _save() {
    final nombre = _nameController.text.trim();
    final puntos = int.tryParse(_pointsController.text.trim()) ?? 0;
    if (nombre.isEmpty || puntos <= 0) {
      setState(() {
        _imageError = 'Nombre y puntos deben ser válidos.';
      });
      return;
    }

    Navigator.of(context).pop(
      Product(
        nombre: nombre,
        puntos: puntos,
        image: normalizeImagePath(_imageController.text),
        imageBytes: _pickedImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Agregar producto' : 'Editar producto',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Puntos del producto',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Imagen (URL o asset .png)',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _selectImage,
                icon: const Icon(Icons.folder_open),
                label: const Text('Seleccionar imagen desde carpeta'),
              ),
              if (_imageError != null) ...[
                const SizedBox(height: 10),
                Text(_imageError!, style: const TextStyle(color: Colors.red)),
              ],
              if (_pickedImage != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_pickedImage!, fit: BoxFit.cover),
                  ),
                ),
                if (_selectedImageName != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _selectedImageName!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(
                        widget.product == null ? 'Agregar' : 'Guardar',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;
  final int puntos;
  final bool? isAdmin;

  const HomePage({
    super.key,
    required this.username,
    required this.puntos,
    this.isAdmin,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _puntos;
  final List<Product> _productos = [];
  final List<Product> _defaultProductos = [
    Product(nombre: 'Camiseta', puntos: 20),
    Product(nombre: 'Taza', puntos: 15),
    Product(nombre: 'Llavero', puntos: 10),
  ];
  final List<Product> _carrito = [];
  final List<List<Product>> _purchaseHistory = [];
  Uint8List? _profileImage;

  bool get _esAdmin => widget.isAdmin == true;

  int get _carritoTotal =>
      _carrito.fold(0, (total, item) => total + item.puntos);

  void _addToCart(Product product) {
    setState(() {
      _carrito.add(
        Product(
          nombre: product.nombre,
          puntos: product.puntos,
          image: product.image,
          imageBytes: product.imageBytes,
        ),
      );
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _carrito.removeAt(index);
    });
  }

  Future<Uint8List?> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        withData: true,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return null;

      return result.files.first.bytes;
    } catch (_) {
      return null;
    }
  }

  Future<List<Product>> _readProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kProductsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final imageBytesBase64 = map['imageBytes']?.toString();
        return Product(
          nombre: map['nombre']?.toString() ?? '',
          puntos: int.tryParse(map['puntos']?.toString() ?? '0') ?? 0,
          image: map['image']?.toString(),
          imageBytes: imageBytesBase64 != null && imageBytesBase64.isNotEmpty
              ? base64Decode(imageBytesBase64)
              : null,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _productos.map((product) {
        return {
          'nombre': product.nombre,
          'puntos': product.puntos,
          'image': product.image,
          'imageBytes': product.imageBytes != null
              ? base64Encode(product.imageBytes!)
              : null,
        };
      }).toList(),
    );
    await prefs.setString(kProductsKey, encoded);
  }

  Future<List<List<Product>>> _readPurchaseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${kPurchaseHistoryKey}:${widget.username}');
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((purchase) {
        final purchaseList = purchase as List<dynamic>;
        return purchaseList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final imageBytesBase64 = map['imageBytes']?.toString();
          return Product(
            nombre: map['nombre']?.toString() ?? '',
            puntos: int.tryParse(map['puntos']?.toString() ?? '0') ?? 0,
            image: map['image']?.toString(),
            imageBytes: imageBytesBase64 != null && imageBytesBase64.isNotEmpty
                ? base64Decode(imageBytesBase64)
                : null,
          );
        }).toList();
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _savePurchaseHistory(List<List<Product>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      history.map((purchase) {
        return purchase.map((product) {
          return {
            'nombre': product.nombre,
            'puntos': product.puntos,
            'image': product.image,
            'imageBytes': product.imageBytes != null
                ? base64Encode(product.imageBytes!)
                : null,
          };
        }).toList();
      }).toList(),
    );
    await prefs.setString('${kPurchaseHistoryKey}:${widget.username}', encoded);
  }

  Future<void> _loadProducts() async {
    final saved = await _readProducts();
    setState(() {
      if (saved.isNotEmpty) {
        _productos.clear();
        _productos.addAll(saved);
      } else {
        _productos.clear();
        _productos.addAll(_defaultProductos);
      }
    });
    await _saveProducts();

    final history = await _readPurchaseHistory();
    setState(() {
      _purchaseHistory.clear();
      _purchaseHistory.addAll(history);
    });
  }

  void _removePurchase(int index) async {
    final purchase = _purchaseHistory[index];
    final totalPoints = purchase.fold(
      0,
      (sum, product) => sum + product.puntos,
    );

    setState(() {
      _puntos -= totalPoints;
      _purchaseHistory.removeAt(index);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKeyFor(widget.username), _puntos);
    await _savePurchaseHistory(_purchaseHistory);
  }

  Future<void> _showAddAdminDialog() async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String? dialogError;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Agregar administrador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              if (dialogError != null) ...[
                const SizedBox(height: 10),
                Text(dialogError!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text.trim();
                final password = passwordController.text;
                if (username.isEmpty || password.length < 4) {
                  setStateDialog(() {
                    dialogError = 'Usuario y contraseña deben ser válidos.';
                  });
                  return;
                }

                final users = await _readUserRecords();
                if (users.containsKey(username)) {
                  setStateDialog(() {
                    dialogError = 'El usuario ya existe.';
                  });
                  return;
                }

                users[username] = {'password': password, 'role': 'admin'};
                await _saveUserRecords(users);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkoutCart() async {
    if (_carrito.isEmpty) return;

    // Capturar los productos comprados antes de vaciar el carrito
    final productosComprados = List<Product>.from(_carrito);

    setState(() {
      _puntos += _carritoTotal;
      _carrito.clear();
      _purchaseHistory.add(productosComprados);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKeyFor(widget.username), _puntos);
    await _savePurchaseHistory(_purchaseHistory);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compra realizada'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Has comprado los siguientes productos:'),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: productosComprados.length,
                  itemBuilder: (context, index) {
                    final product = productosComprados[index];
                    return ListTile(
                      dense: true,
                      leading: _buildProductImage(product),
                      title: Text(product.nombre),
                      subtitle: Text('Puntos: ${product.puntos}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          product.imageBytes!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (product.image != null && product.image!.isNotEmpty) {
      final imagePath = product.image!;
      if (imagePath.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imagePath,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey,
            ),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey,
          ),
        ),
      );
    }
    return const Icon(Icons.shopping_bag, size: 40, color: Colors.deepPurple);
  }

  @override
  void initState() {
    super.initState();
    _puntos = widget.puntos;
    _loadProducts();
  }

  String _pointsKeyFor(String username) => 'puntos:$username';

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kLoggedInKey, false);
    await prefs.remove(kUsernameKey);

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _agregarPuntos(int valor) async {
    setState(() {
      _puntos += valor;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKeyFor(widget.username), _puntos);

    if (valor < 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Felicidades!'),
          content: const Text('Has ganado un premio'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showProductForm({int? index}) async {
    final product = index == null ? null : _productos[index];
    final newProduct = await Navigator.of(context).push<Product?>(
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );

    if (newProduct == null) return;

    setState(() {
      if (index == null) {
        _productos.add(newProduct);
      } else {
        _productos[index] = newProduct;
      }
    });
    await _saveProducts();
  }

  void _deleteProduct(int index) {
    setState(() {
      _productos.removeAt(index);
    });
    _saveProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos y Recompensas'),
        actions: [
          if (_esAdmin)
            IconButton(
              onPressed: _showAddAdminDialog,
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Agregar administrador',
            ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: _esAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showProductForm(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar producto'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${widget.username}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Puntos acumulados: $_puntos',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            if (_purchaseHistory.isNotEmpty)
              ExpansionTile(
                title: const Text('Historial de compras'),
                children: _purchaseHistory.asMap().entries.map((entry) {
                  final index = entry.key;
                  final purchase = entry.value;
                  final totalPoints = purchase.fold(
                    0,
                    (sum, product) => sum + product.puntos,
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Compra ${index + 1} - ${purchase.length} producto${purchase.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removePurchase(index),
                                tooltip: 'Eliminar compra y devolver puntos',
                              ),
                            ],
                          ),
                          Text('Total puntos gastados: $totalPoints'),
                          const SizedBox(height: 8),
                          ...purchase.map(
                            (product) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: _buildProductImage(product),
                              title: Text(product.nombre),
                              subtitle: Text('Puntos: ${product.puntos}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _puntos >= 50 ? () => _agregarPuntos(-50) : null,
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Canjear premio (50 puntos)'),
            ),
            if (_puntos < 50)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Necesitas 50 puntos para canjear.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 24),
            if (_carrito.isNotEmpty) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Carrito de compras',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          itemCount: _carrito.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _carrito[index];
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.nombre),
                              subtitle: Text('Puntos: ${item.puntos}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeFromCart(index),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: $_carritoTotal puntos',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: _checkoutCart,
                            child: const Text('Comprar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Productos disponibles',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: _productos.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final product = _productos[index];
                  return Card(
                    child: ListTile(
                      leading: _buildProductImage(product),
                      title: Text(product.nombre),
                      subtitle: Text('Puntos: ${product.puntos}'),
                      trailing: _esAdmin
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showProductForm(index: index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteProduct(index),
                                ),
                              ],
                            )
                          : IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () => _addToCart(product),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
