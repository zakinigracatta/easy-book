import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final List<Map<String, dynamic>> _cart = [];
  double get _total => _cart.fold(0.0, (sum, item) => sum + (item['price'] as double));

  void _addItem(String name, double price) {
    setState(() {
      _cart.add({'name': name, 'price': price});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS Register')),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Services Catalog Selection
                Expanded(
                  flex: 3,
                  child: GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildPosItem('Haircut', 45.0),
                      _buildPosItem('Beard Trim', 25.0),
                      _buildPosItem('Hair Color', 85.0),
                      _buildPosItem('Head Spa', 60.0),
                      _buildPosItem('Face Massage', 50.0),
                      _buildPosItem('Royal Shave', 35.0),
                    ],
                  ),
                ),

                // Current Order Cart Panel
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const Divider(),
                        Expanded(
                          child: _cart.isEmpty
                              ? const Center(child: Text('Cart is empty'))
                              : ListView.builder(
                                  itemCount: _cart.length,
                                  itemBuilder: (context, index) {
                                    final item = _cart[index];
                                    return ListTile(
                                      title: Text(item['name'] as String),
                                      trailing: Text('\$${item['price']}'),
                                    );
                                  },
                                ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6C3EF4))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Checkout & Pay',
                          onPressed: _cart.isEmpty
                              ? () {}
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Payment processed successfully!')),
                                  );
                                  setState(() => _cart.clear());
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosItem(String name, double price) {
    return GestureDetector(
      onTap: () => _addItem(name, price),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text('\$$price', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
