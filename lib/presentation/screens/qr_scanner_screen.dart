import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController =
      MobileScannerController();
  final skuController = TextEditingController();
  bool _isReturning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'QR Scanner',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  radius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          height: 240,
                          width: double.infinity,
                          child: MobileScanner(
                            controller: _scannerController,
                            onDetect: (capture) {
                              if (_isReturning) return;
                              final barcode = capture.barcodes.isNotEmpty
                                  ? capture.barcodes.first
                                  : null;
                              final value = barcode?.rawValue ?? '';
                              if (value.trim().isEmpty) return;
                              _isReturning = true;
                              Get.back(result: value.trim());
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: skuController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Enter SKU manually',
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassButton(
                        label: 'Simulate Scan',
                        onTap: () async {
                          final sku = skuController.text.trim().isNotEmpty
                              ? skuController.text.trim()
                              : '';
                          if (sku.isEmpty) return;
                          if (mounted) Get.back(result: sku);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
