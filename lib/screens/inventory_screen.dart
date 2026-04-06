import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirestoreService _service = FirestoreService();

  // Opens a dialog to ADD or EDIT an item
  void _showItemDialog({Item? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final qtyController = TextEditingController(text: existing?.quantity.toString() ?? '');
    final priceController = TextEditingController(text: existing?.price.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Item' : 'Edit Item'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // NAME FIELD
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Name cannot be empty' : null,
              ),

              // QUANTITY FIELD
              TextFormField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Quantity cannot be empty';
                  if (int.tryParse(val) == null) return 'Must be a whole number';
                  if (int.parse(val) < 0) return 'Cannot be negative';
                  return null;
                },
              ),

              // PRICE FIELD
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Price cannot be empty';
                  if (double.tryParse(val) == null) return 'Must be a valid number';
                  if (double.parse(val) < 0) return 'Cannot be negative';
                  return null;
                },
              ),

            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final item = Item(
                id: existing?.id ?? '',
                name: nameController.text.trim(),
                quantity: int.parse(qtyController.text.trim()),
                price: double.parse(priceController.text.trim()),
              );

              if (existing == null) {
                await _service.addItem(item);
              } else {
                await _service.updateItem(item);
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ).then((_) {
      // Dispose controllers after dialog closes
      nameController.dispose();
      qtyController.dispose();
      priceController.dispose();
    });
  }

  // Confirm before deleting
  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _service.deleteItem(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Item>>(
        stream: _service.streamItems(),
        builder: (context, snapshot) {

          // LOADING STATE
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR STATE
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          // EMPTY STATE
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No items yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // LIST
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Qty: ${item.quantity}  ·  \$${item.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showItemDialog(existing: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}