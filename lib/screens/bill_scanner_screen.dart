import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'add_expense_screen.dart';

class BillScannerScreen extends StatefulWidget {
  const BillScannerScreen({super.key});

  @override
  State<BillScannerScreen> createState() => _BillScannerScreenState();
}

class _BillScannerScreenState extends State<BillScannerScreen> {
  File? _pickedImage;
  String? _recognizedText;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera); // or .gallery
    if (pickedFile == null) return;

    setState(() => _pickedImage = File(pickedFile.path));

    final inputImage = InputImage.fromFile(_pickedImage!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _recognizedText = recognizedText.text;
    });

    textRecognizer.close();
  }

  void _addExpenseFromText() {
    if (_recognizedText == null) return;

    final lines = _recognizedText!.split('\n');
    String? title;
    double? amount;

    for (var line in lines) {
      if (title == null && line.trim().isNotEmpty) {
        title = line.trim();
      }
      final regex = RegExp(r'₹?\s?(\d+(\.\d{1,2})?)');
      final match = regex.firstMatch(line);
      if (match != null) {
        amount = double.tryParse(match.group(1)!);
      }
      if (title != null && amount != null) break;
    }

    if (title != null && amount != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AddExpenseScreen(
            prefillTitle: title!,
            prefillAmount: amount!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not extract title or amount.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Bill')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            onPressed: _pickImage,
            label: const Text('Scan Bill'),
          ),
          if (_pickedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(_pickedImage!),
            ),
          if (_recognizedText != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(_recognizedText ?? ''),
                ),
              ),
            ),
          if (_recognizedText != null)
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add This Expense'),
              onPressed: _addExpenseFromText,
            ),
        ],
      ),
    );
  }
}
