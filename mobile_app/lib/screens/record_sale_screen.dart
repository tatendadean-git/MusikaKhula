import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sale.dart';
import '../models/inventory_item.dart';
import '../services/database_helper.dart';

class RecordSaleScreen extends StatefulWidget {
  const RecordSaleScreen({super.key});

  @override
  State<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends State<RecordSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper.instance;

  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _unitPriceController = TextEditingController();

  List<InventoryItem> _availableInventory = [];
  InventoryItem? _selectedItem;

  String _selectedCurrency = 'USD';
  String _selectedPaymentMethod = 'Cash';
  double _calculatedProfit = 0.0;
  List<Sale> _todaysSales = [];

  final List<String> _currencies = ['USD', 'ZiG', 'ZAR'];
  final List<String> _paymentMethods = ['Cash', 'EcoCash', 'OneMoney', 'Credit given (Chikwereti)'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _qtyController.addListener(_updateProfit);
    _unitPriceController.addListener(_updateProfit);
  }

  void _loadInitialData() async {
    final inventory = await _db.getAllInventory();
    final sales = await _db.getTodaysSales();
    setState(() {
      _availableInventory = inventory;
      _todaysSales = sales;
      if (inventory.isNotEmpty) {
        _selectedItem = inventory.first;
        _updateProfit();
      }
    });
  }

  void _updateProfit() {
    final String priceText = _unitPriceController.text.trim();
    final String qtyText = _qtyController.text.trim();

    if (priceText.isEmpty || double.tryParse(priceText) == null || int.tryParse(qtyText) == null) {
      setState(() {
        _calculatedProfit = 0.00;
      });
      return;
    }

    final int qty = int.parse(qtyText);
    final double unitPrice = double.parse(priceText);
    final double costPrice = _selectedItem?.costPrice ?? 0.0;

    setState(() {
      _calculatedProfit = (unitPrice - costPrice) * qty;
    });
  }

  void _handleSaveSale() async {
    if (_formKey.currentState!.validate() && _selectedItem != null) {
      final int inputQty = int.parse(_qtyController.text);

      if (_selectedItem!.quantity < inputQty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Insufficient inventory stock! Current quantity: ${_selectedItem!.quantity}'),
            backgroundColor: Colors.orange.shade800,
          ),
        );
        return;
      }

      final newSale = Sale(
        productName: _selectedItem!.productName,
        category: _selectedItem!.category,
        quantity: inputQty,
        unitPrice: double.parse(_unitPriceController.text),
        costPrice: _selectedItem!.costPrice,
        currency: _selectedCurrency,
        paymentMethod: _selectedPaymentMethod,
        saleDate: DateTime.now(),
      );

      await _db.insertSale(newSale);

      _qtyController.text = '1';
      _unitPriceController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction successfully tracked locally!'), backgroundColor: Color(0xFF0F6E56)),
      );
      _loadInitialData();
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F6E56), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      appBar: AppBar(title: const Text('Record New Sale')),
      body: _availableInventory.isEmpty
          ? const Center(child: Text('Inventory ledger matches empty states. Add items to stock track tab first.'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DropdownButtonFormField<InventoryItem>(
                                    value: _selectedItem,
                                    decoration: _buildInputDecoration('Product Name'),
                                    items: _availableInventory.map((item) {
                                      return DropdownMenuItem(value: item, child: Text(item.productName));
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedItem = val;
                                        _updateProfit();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    key: ValueKey('${_selectedItem?.productName}_cat'),
                                    initialValue: _selectedItem?.category ?? '',
                                    enabled: false,
                                    decoration: _buildInputDecoration('Product Category (Auto-filled)'),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    key: ValueKey('${_selectedItem?.productName}_cost'),
                                    initialValue: _selectedItem != null 
                                        ? '\$${_selectedItem!.costPrice.toStringAsFixed(2)} $_selectedCurrency' 
                                        : '',
                                    enabled: false,
                                    decoration: _buildInputDecoration('Original Item Cost Price (Read-Only)'),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: _qtyController,
                                          keyboardType: TextInputType.number,
                                          decoration: _buildInputDecoration('Quantity'),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) return 'Required';
                                            final val = int.tryParse(v);
                                            if (val == null || val <= 0) return 'Must be > 0';
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          controller: _unitPriceController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: _buildInputDecoration('Unit Selling Price ($_selectedCurrency)'),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) return 'Required';
                                            final val = double.tryParse(v);
                                            if (val == null || val <= 0) return 'Must be > 0';
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _selectedCurrency,
                                    decoration: _buildInputDecoration('Currency'),
                                    items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                    onChanged: (v) => setState(() => _selectedCurrency = v!),
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _selectedPaymentMethod,
                                    decoration: _buildInputDecoration('Payment Method'),
                                    items: _paymentMethods.map((pm) => DropdownMenuItem(value: pm, child: Text(pm))).toList(),
                                    onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Profit: $_selectedCurrency ${_calculatedProfit.toStringAsFixed(2)}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(color: Color(0xFF0F6E56), fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text("Today's Sales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _todaysSales.length,
                            itemBuilder: (context, index) {
                              final sale = _todaysSales[index];
                              return Card(
                                elevation: 0,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                                child: ListTile(
                                  title: Text(sale.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${sale.category} • Qty: ${sale.quantity} • ${sale.paymentMethod}'),
                                  trailing: Text('${sale.currency} ${sale.revenue.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF0F6E56), fontWeight: FontWeight.bold)),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleSaveSale,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F6E56), foregroundColor: Colors.white),
                        child: const Text('Save Sale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
