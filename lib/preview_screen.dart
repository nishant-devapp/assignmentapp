import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'product_model.dart';

class PreviewScreen extends StatelessWidget {
  final List<Product> products;
  final String userName;
  final String userEmail;

  const PreviewScreen({
    super.key,
    required this.products,
    required this.userName,
    required this.userEmail,
  });

  Future<File> _generatePdfAndSave() async {
    final pdf = pw.Document();
    double totalPrice = products.fold(0, (sum, product) => sum + product.price);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Name: $userName', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Email: $userEmail', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.Text('Products:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(product.name, style: const pw.TextStyle(fontSize: 16)),
                    pw.Text('Rs.${product.price.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
                  ],
                );
              },
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Price:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('Rs.${totalPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );

    Directory dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.pdf');
    print(file);
    await file.writeAsBytes(await pdf.save());
    return file;
  }


  void _downloadPdf(BuildContext context) async {
    try {
      // Check and request permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Storage permission not granted")));
          return;
        }
      }

      final file = await _generatePdfAndSave();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF saved at ${file.path}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _sharePdf(BuildContext context) async {
    try {
      final file = await _generatePdfAndSave();
      await Share.shareXFiles([XFile(file.path)], text: 'Here is your PDF preview.');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = products.fold(0, (sum, product) => sum + product.price);
    return Scaffold(
      appBar: AppBar(title: const Text("Preview")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $userName", style: const TextStyle(fontSize: 16)),
            Text("Email: $userEmail", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product.name, style: const TextStyle(fontSize: 18.0)),
                    trailing: Text("Rs.${product.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16.0)),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Price:', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600)),
                Text("Rs.${totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 60.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _downloadPdf(context),
                    child: const Text("Download PDF"),
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _sharePdf(context),
                    child: const Text("Share PDF"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
