import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      'Vendor Intelligence',
      'Change Language',
      'Disable Offline Mode',
      'Toggle Dark/Light Mode',
      'Data Sync Status',
      'Voice Mode',
      'Backup & Restore',
      'Support Chat',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('More', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListTile(
              title: Center(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$item selected (coming soon)')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
