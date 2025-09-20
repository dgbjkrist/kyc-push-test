// main.dart (ou screen)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'extraction.dart';

class IdExtractScreen extends StatefulWidget {
  const IdExtractScreen({super.key});

  @override
  State<IdExtractScreen> createState() => _IdExtractScreenState();
}

class _IdExtractScreenState extends State<IdExtractScreen> {
  File? _image;
  String _ocrText = '';
  ExtractedInfo? _result;
  bool _busy = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _ocrText = '';
      _result = null;
    });
    await _extractFromImage(_image!);
  }

  Future<void> _extractFromImage(File image) async {
    setState(() { _busy = true; });

    try {
      final text = await recognizeTextFromImage(image);
      setState(() { _ocrText = text; });
      print(":::::::::::::::::");
      print("OCR text: $text");
      print(":::::::::::::::::");

      // 1) try MRZ
      final mrz = parseMRZ(text);
      if (mrz != null) {
        setState(() { _result = mrz; });
        return;
      }

      // 2) heuristics fallback
      final heur = parseHeuristics(text);
      setState(() { _result = heur; });
    } finally {
      setState(() { _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ID Extractor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _busy ? null : _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: Text(_busy ? 'Processing...' : 'Take photo'),
            ),
            const SizedBox(height: 12),
            if (_image != null) Image.file(_image!, height: 200),
            const SizedBox(height: 12),
            if (_result != null) ...[
              Text('Extracted JSON:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SelectableText(_result!.toJson().toString()),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text('OCR raw text:\n\n$_ocrText'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
