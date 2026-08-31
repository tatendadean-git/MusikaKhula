class InventoryItem{
  final int? id;
  final String productName;
  final String category;
  final int quantity;
  final double costPrice;
  final int lowStockThreshold;
  final bool isSynced;

  InventoryItem ({
    this.id,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.costPrice,
    this.lowStockThreshold = 10,
    this.isSynced = false,
});

  String get stockStatus {
    if (quantity <= 0) return "Out of Stock";
    if (quantity <= lowStockThreshold) return 'Low';
    if (quantity <= lowStockThreshold * 3) return 'Medium';
    return 'High';
  }

  Map<String, dynamic> toMap() => {
    'id' : id,
    'product_name' : productName,
    'category' : category,
    'quantity' : quantity,
    'cost_price' : costPrice,
    'low_stock_threshold' : lowStockThreshold,
    'is_synced' : isSynced ? 1 : 0 ,
  };

  factory InventoryItem.fromMap(Map<String, dynamic> m) => InventoryItem(
    id: m['id'],
    productName: m['product_name'],
    category: m['category'],
    quantity: m['quantity'],
    costPrice: m['cost_price'],
    lowStockThreshold: m['low_stock_threshold'],
    isSynced: m['is_synced'] == 1,
  );
}