import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../theme/prestige_theme.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _pointsController = TextEditingController();
  
  String? _imageDataBase64;
  String? _imageName;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _imageDataBase64 = base64Encode(file.bytes!);
            _imageName = file.name;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageDataBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar una imagen')),
      );
      return;
    }

    setState(() => _saving = true);

    final session = await AuthService().checkSavedSession();
    final username = session?.username ?? 'guest';

    final product = {
      'title': _titleController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'pointsOnPurchase': int.tryParse(_pointsController.text) ?? 0,
      'imageData': _imageDataBase64,
      'imageName': _imageName,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await AuthService().addCustomProduct(username: username, product: product);

    setState(() => _saving = false);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar producto'),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        iconTheme: const IconThemeData(color: PrestigeColors.primaryContainer),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Información del Producto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PrestigeColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Nombre del producto',
                  hintText: 'Ej: Laptop Gaming',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.shopping_bag),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa el nombre del producto' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Precio del producto',
                  hintText: 'Ej: 2500.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa el precio';
                  if (double.tryParse(v) == null) return 'Precio inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pointsController,
                decoration: InputDecoration(
                  labelText: 'Puntos que da al comprar',
                  hintText: 'Ej: 100',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.stars),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa los puntos';
                  if (int.tryParse(v) == null) return 'Puntos inválidos';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Imagen del producto',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: PrestigeColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _imageDataBase64 != null
                        ? PrestigeColors.secondary
                        : PrestigeColors.outlineVariant,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageDataBase64 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          base64Decode(_imageDataBase64!),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: PrestigeColors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sin imagen seleccionada',
                              style: TextStyle(
                                color: PrestigeColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Seleccionar imagen desde tu escritorio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrestigeColors.primaryContainer,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (_imageName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Archivo: $_imageName',
                  style: TextStyle(
                    fontSize: 12,
                    color: PrestigeColors.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveProduct,
                  icon: _saving ? const SizedBox.shrink() : const Icon(Icons.save),
                  label: _saving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Guardar producto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrestigeColors.secondaryContainer,
                    foregroundColor: PrestigeColors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
