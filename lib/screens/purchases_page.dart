import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/prestige_theme.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    final session = await AuthService().checkSavedSession();
    _username = session?.username ?? 'guest';
    final products = await AuthService().getCustomProducts(_username);
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  Future<void> _editProduct(int index, Map<String, dynamic> product) async {
    final titleController = TextEditingController(
      text: product['title']?.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: product['price']?.toString() ?? '',
    );
    final pointsController = TextEditingController(
      text: product['pointsOnPurchase']?.toString() ?? '',
    );

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Editar producto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Precio'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Puntos por compra',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'La imagen se conserva como está.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      if (titleController.text.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre no puede quedar vacío')),
        );
        return;
      }

      final updatedProduct = Map<String, dynamic>.from(product)
        ..['title'] = titleController.text.trim()
        ..['price'] = double.tryParse(priceController.text.trim()) ?? 0.0
        ..['pointsOnPurchase'] =
            int.tryParse(pointsController.text.trim()) ?? 0;

      await AuthService().updateCustomProduct(
        username: _username,
        index: index,
        product: updatedProduct,
      );

      await _loadProducts();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto actualizado')));
    } finally {
      titleController.dispose();
      priceController.dispose();
      pointsController.dispose();
    }
  }

  Future<void> _deleteProduct(int index, Map<String, dynamic> product) async {
    final title = product['title']?.toString() ?? 'Producto';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Seguro que quieres eliminar "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await AuthService().deleteCustomProduct(username: _username, index: index);

    await _loadProducts();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
  }

  Future<void> _buyProduct(Map<String, dynamic> product) async {
    final title = product['title']?.toString() ?? 'Producto';
    final pointsToAdd = (product['pointsOnPurchase'] ?? 0) as int;
    final imageData = product['imageData']?.toString() ?? '';

    // Obtener sesión actual para obtener puntos
    final session = await AuthService().checkSavedSession();
    final currentPoints = session?.points ?? 0;
    final newPoints = currentPoints + pointsToAdd;

    // Actualizar puntos en Supabase
    await AuthService().savePoints(username: _username, points: newPoints);

    // Agregar entrada al historial
    await AuthService().addHistoryEntry(
      username: _username,
      entry: {
        'date': DateTime.now().toIso8601String(),
        'title': title,
        'description': 'Compra realizada desde Mis Productos',
        'pointsSpent': '+$pointsToAdd pts',
        'imageUrl': imageData,
        'status': 'Confirmed',
      },
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡$title agregada al historial! +$pointsToAdd pts'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Productos'),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        iconTheme: const IconThemeData(color: PrestigeColors.primaryContainer),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: PrestigeColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos registrados.',
                    style: TextStyle(
                      color: PrestigeColors.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final p = _products[index];
                final imageData = p['imageData']?.toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: PrestigeColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Container(
                              width: 100,
                              height: 100,
                              color: PrestigeColors.surfaceContainerLow,
                              child: imageData != null && imageData.isNotEmpty
                                  ? Image.memory(
                                      base64Decode(imageData),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const Icon(Icons.image_not_supported),
                                    )
                                  : const Icon(Icons.image),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['title']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: PrestigeColors.primary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: 16,
                                        color: PrestigeColors.secondary,
                                      ),
                                      Text(
                                        '${p['price'] ?? 0}',
                                        style: const TextStyle(
                                          color: PrestigeColors.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.stars,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      Text(
                                        '+${p['pointsOnPurchase'] ?? 0} pts',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      Divider(
                        height: 1,
                        color: PrestigeColors.outlineVariant.withOpacity(0.2),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _editProduct(index, p),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Editar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _deleteProduct(index, p),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                    ),
                                    label: const Text('Eliminar'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton.icon(
                                onPressed: () => _buyProduct(p),
                                icon: const Icon(Icons.shopping_cart, size: 18),
                                label: const Text('Comprar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      PrestigeColors.secondaryContainer,
                                  foregroundColor:
                                      PrestigeColors.onSecondaryContainer,
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
