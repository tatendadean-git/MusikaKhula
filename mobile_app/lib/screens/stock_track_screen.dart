import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/inventory_item.dart';
import '../services/database_helper.dart';

class StockTrackScreen extends StatefulWidget {
  const StockTrackScreen({super.key});

  @override
  State<StockTrackScreen> createState() => _StockTrackScreenState();
}

class _StockTrackScreenState extends State<StockTrackScreen> {
  List<InventoryItem> _inventoryList = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'Groceries',
    'Fresh Produce',
    'Electronics',
    'Clothing',
    'Hardware',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStockData();
  }

  Future<void> _fetchStockData() async {
    setState(() => _isLoading = true);
    try {
      final items = await DatabaseHelper.instance.getAllInventory();
      setState(() {
        _inventoryList = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddProductDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final costController = TextEditingController();
    String selectedCategory = _categories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Inventory Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setDialogState(() => selectedCategory = val ?? _categories.first),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final val = int.tryParse(v);
                      if (val == null || val < 0) return 'Valid qty required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: costController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Cost Price (USD)', hintText: 'e.g., 0.20'),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final val = double.tryParse(v);
                      if (val == null || val < 0) return 'Valid cost required';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F6E56), foregroundColor: Colors.white),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = nameController.text.trim();
                final qty = int.parse(qtyController.text);
                final cost = double.parse(costController.text);

                // Check if product already exists
                final existing = _inventoryList.where((i) => i.productName.toLowerCase() == name.toLowerCase()).firstOrNull;
                if (existing != null) {
                  if (context.mounted) Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('⚠️ "$name" already exists! Please tap the item to use Quick Restock.'),
                        backgroundColor: Colors.orange.shade800,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                  return;
                }

                final newItem = InventoryItem(
                  productName: name,
                  category: selectedCategory,
                  quantity: qty,
                  costPrice: cost,
                );
                await DatabaseHelper.instance.insertInventoryItem(newItem);
                if (context.mounted) Navigator.pop(context);
                _fetchStockData();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestockDialog(BuildContext context, InventoryItem item) {
    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController(text: item.quantity.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${item.productName} Stock'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'New Stock Balance Total'),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              final val = int.tryParse(v);
              if (val == null || val < 0) return 'Valid qty required';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F6E56), foregroundColor: Colors.white),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newQty = int.parse(quantityController.text);
              if (item.id != null) {
                await DatabaseHelper.instance.updateStock(item.id!, newQty);
                if (context.mounted) {
                  Navigator.pop(context);
                  _fetchStockData();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, InventoryItem item) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item.productName);
    final qtyController = TextEditingController(text: item.quantity.toString());
    final costController = TextEditingController(text: item.costPrice.toString());
    String selectedCategory = _categories.contains(item.category) ? item.category : _categories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${item.productName}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setDialogState(() => selectedCategory = val ?? _categories.first),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final val = int.tryParse(v);
                      if (val == null || val < 0) return 'Valid qty required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: costController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Cost Price (USD)'),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final val = double.tryParse(v);
                      if (val == null || val < 0) return 'Valid cost required';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F6E56), foregroundColor: Colors.white),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = nameController.text.trim();
                final qty = int.parse(qtyController.text);
                final cost = double.parse(costController.text);
                if (item.id != null) {
                  final updatedItem = InventoryItem(
                    id: item.id,
                    productName: name,
                    category: selectedCategory,
                    quantity: qty,
                    costPrice: cost,
                  );
                  await DatabaseHelper.instance.updateInventoryItem(updatedItem);
                  if (context.mounted) Navigator.pop(context);
                  _fetchStockData();
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInventoryContextMenu(BuildContext context, InventoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Manage: ${item.productName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Color(0xFF0F6E56)),
                title: const Text('Quick Restock'),
                subtitle: const Text('Update active stock balance total'),
                onTap: () {
                  Navigator.pop(context);
                  _showRestockDialog(context, item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note, color: Color(0xFF0F6E56)),
                title: const Text('Fix Mistake / Edit Details'),
                subtitle: const Text('Change product name, category, or current cost price base'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditItemDialog(context, item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                title: const Text('Delete Product Listing', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Permanently remove item from active stock records'),
                onTap: () async {
                  if (item.id != null) {
                    await DatabaseHelper.instance.deleteInventoryItem(item.id!);
                    if (context.mounted) Navigator.pop(context);
                    _fetchStockData();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Real-time stock tracking (Tap item for options)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inventoryList.isEmpty
              ? const Center(child: Text('No inventory items found. Add items to track stock.'))
              : RefreshIndicator(
                  onRefresh: _fetchStockData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _inventoryList.length,
                    itemBuilder: (context, index) {
                      final item = _inventoryList[index];
                      final status = item.stockStatus;
                      
                      Color badgeColor = Colors.green;
                      Color textColor = Colors.white;

                      if (status == 'Medium') {
                        badgeColor = Colors.amber;
                        textColor = Colors.black87;
                      } else if (status == 'Low' || status == 'Out of Stock') {
                        badgeColor = Colors.red;
                        textColor = Colors.white;
                      } else {
                        badgeColor = Colors.green;
                        textColor = Colors.white;
                      }

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showInventoryContextMenu(context, item),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Category: ${item.category} • In Stock: ${item.quantity}',
                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
