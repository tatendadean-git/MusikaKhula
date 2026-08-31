class Sale {
  final int? id;
  final String productName;
  final String category;
  final int quantity;
  final double unitPrice;
  final double costPrice;
  final String currency;
  final String paymentMethod;
  final DateTime saleDate;
  final bool isSynced;

  Sale({
    this.id,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
    this.currency = 'USD',
    this.paymentMethod = 'Cash',
    required this.saleDate,
    this.isSynced = false,
  });

  double get profit => (unitPrice - costPrice) * quantity;
  double get revenue => unitPrice * quantity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'product_name': productName,
    'category': category,
    'quantity': quantity,
    'unit_price': unitPrice,
    'cost_price': costPrice,
    'currency': currency,
    'payment_method': paymentMethod,
    'sale_date': saleDate.toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
  };

  factory Sale.fromMap(Map<String, dynamic> m) => Sale(
    id: m['id'],
    productName: m['product_name'],
    category: m['category'],
    quantity: m['quantity'],
    unitPrice: m['unit_price'],
    costPrice: m['cost_price'],
    currency: m['currency'],
    paymentMethod: m['payment_method'],
    saleDate: DateTime.parse(m['sale_date']),
    isSynced: m['is_synced'] == 1,
  );
}
