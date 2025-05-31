import 'package:assignment/preview_screen.dart';
import 'package:assignment/product_model.dart';
import 'package:flutter/material.dart';


class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<Product> products = [
    Product(name: "Apple", price: 30),
    Product(name: "Banana", price: 10),
    Product(name: "Orange", price: 20),
    Product(name: "Milk", price: 50),
    Product(name: "Bread", price: 40),
  ];

  final List<Product> selectedProducts = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void _generatePdf() {
    if (selectedProducts.isEmpty) {
      _showSnackBar('Select at least one product');
    } else if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter name and email');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewScreen(
            products: selectedProducts,
            userName: nameController.text.trim(),
            userEmail: emailController.text.trim(),
          ),
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Products")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...products.map((product) {
              return CheckboxListTile(
                title: Text('${product.name} - ₹${product.price}'),
                value: selectedProducts.contains(product),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      selectedProducts.add(product);
                    } else {
                      selectedProducts.remove(product);
                    }
                  });
                },
              );
            }),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generatePdf,
              child: const Text("Generate PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
