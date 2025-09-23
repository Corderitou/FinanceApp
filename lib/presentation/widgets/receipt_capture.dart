import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiptCaptureService {
  final ImagePicker _picker = ImagePicker();

  /// Capture receipt image using camera
  Future<File?> captureReceiptImage() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Camera permission denied');
      }

      // Capture image
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      print('Error capturing receipt image: $e');
      return null;
    }
  }

  /// Select receipt image from gallery
  Future<File?> selectReceiptImage() async {
    try {
      // Request gallery permission
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Storage permission denied');
      }

      // Select image
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      print('Error selecting receipt image: $e');
      return null;
    }
  }

  /// Extract text from receipt image using OCR
  Future<ReceiptData> extractReceiptData(File imageFile) async {
    // In a real implementation, this would use an OCR service like Google ML Kit or Firebase ML
    // For now, we'll return mock data
    
    // Simulate OCR processing time
    await Future.delayed(const Duration(seconds: 2));
    
    return ReceiptData(
      merchantName: 'Sample Store',
      date: DateTime.now(),
      totalAmount: 25.99,
      items: [
        ReceiptItem(name: 'Item 1', price: 10.99),
        ReceiptItem(name: 'Item 2', price: 15.00),
      ],
    );
  }
}

class ReceiptData {
  final String merchantName;
  final DateTime date;
  final double totalAmount;
  final List<ReceiptItem> items;

  ReceiptData({
    required this.merchantName,
    required this.date,
    required this.totalAmount,
    required this.items,
  });
}

class ReceiptItem {
  final String name;
  final double price;

  ReceiptItem({
    required this.name,
    required this.price,
  });
}

class ReceiptCaptureWidget extends StatefulWidget {
  final Function(ReceiptData) onReceiptCaptured;

  const ReceiptCaptureWidget({
    Key? key,
    required this.onReceiptCaptured,
  }) : super(key: key);

  @override
  _ReceiptCaptureWidgetState createState() => _ReceiptCaptureWidgetState();
}

class _ReceiptCaptureWidgetState extends State<ReceiptCaptureWidget> {
  final ReceiptCaptureService _receiptService = ReceiptCaptureService();
  bool _isProcessing = false;

  Future<void> _captureReceipt() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final imageFile = await _receiptService.captureReceiptImage();
      if (imageFile != null) {
        final receiptData = await _receiptService.extractReceiptData(imageFile);
        widget.onReceiptCaptured(receiptData);
      }
    } catch (e) {
      _showError('Failed to capture receipt: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _selectReceipt() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final imageFile = await _receiptService.selectReceiptImage();
      if (imageFile != null) {
        final receiptData = await _receiptService.extractReceiptData(imageFile);
        widget.onReceiptCaptured(receiptData);
      }
    } catch (e) {
      _showError('Failed to select receipt: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _captureReceipt,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Capture Receipt'),
        ),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _selectReceipt,
          icon: const Icon(Icons.photo_library),
          label: const Text('Select Receipt'),
        ),
      ],
    );
  }
}