import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ExtractedInfo {
  final String fullName;
  final String dateOfBirth;
  final String nationality;
  ExtractedInfo({required this.fullName, required this.dateOfBirth, required this.nationality});
  Map<String, String> toJson() => {'full_name': fullName, 'date_of_birth': dateOfBirth, 'nationality': nationality};
}

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(); // you may inject to mock in tests

  Future<String> recognizeTextFromImagePath(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _recognizer.processImage(inputImage);
    final buffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) buffer.writeln(line.text);
    }
    return buffer.toString();
  }

  Future<ExtractedInfo?> extractFromImage(String imagePath) async {
    final text = await recognizeTextFromImagePath(imagePath);
    final mrz = _parseMRZ(text);
    if (mrz != null) return mrz;
    final heur = _parseHeuristics(text);
    return heur;
  }

  /// Attempt parsing MRZ (passport / travel document)
  /// Returns ExtractedInfo if MRZ found and parsed, otherwise null.
  ExtractedInfo? _parseMRZ(String text) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.replaceAll(' ', '').trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Look for lines typical of MRZ: they contain '<' and often length 44 (passport)
    final mrzLines = lines.where((l) => l.contains('<')).toList();
    if (mrzLines.length < 2) return null;

    // take first two candidate lines of MRZ (passport most often 2 lines)
    final line1 = mrzLines[0];
    final line2 = mrzLines[1];

    try {
      // line1: P<COUNTRYSURNAME<<GIVENNAMES
      // split surname and given names by '<<'
      var t1 = line1;
      if (t1.startsWith('P<') || t1.startsWith('V<')) {
        t1 = t1.substring(2);
      }
      final parts = t1.split('<<');
      final surname = parts.isNotEmpty ? parts[0].replaceAll('<', ' ').trim() : '';
      final given = parts.length > 1 ? parts[1].replaceAll('<', ' ').trim() : '';
      final fullName = ('$given $surname').trim();

      // line2 positions (passport MRZ standard):
      // passportNo (0..8), check (9), nationality (10..12), dob(13..18) YYMMDD etc.
      final nat = (line2.length >= 13) ? line2.substring(10, 13).replaceAll('<', '') : '';
      final dobYYMMDD = (line2.length >= 19) ? line2.substring(13, 19) : null;

      String dobIso = '';
      if (dobYYMMDD != null && dobYYMMDD.length == 6) {
        final yy = int.parse(dobYYMMDD.substring(0, 2));
        final mm = dobYYMMDD.substring(2, 4);
        final dd = dobYYMMDD.substring(4, 6);
        // heuristic to choose century:
        final year = (yy > 30) ? 1900 + yy : 2000 + yy;
        dobIso = '$year-$mm-$dd';
      }

      return ExtractedInfo(
        fullName: fullName.isEmpty ? '' : fullName,
        dateOfBirth: dobIso,
        nationality: nat,
      );
    } catch (e) {
      return null;
    }
  }


  ExtractedInfo _parseHeuristics(String text) {
    // adapted from your parseHeuristics:
    final lines = text.split(RegExp(r'[\r\n]+')).map((l)=>l.trim()).where((l)=>l.isNotEmpty).toList();
    String name = '';
    String dob = '';
    String nationality = '';
    // 1) try to find a date (DD/MM/YYYY, YYYY-MM-DD, DD-MM-YYYY, D MMM YYYY etc.)
    final datePatterns = [
      RegExp(r'(\d{4}-\d{2}-\d{2})'), // YYYY-MM-DD
      RegExp(r'(\d{2}/\d{2}/\d{4})'), // DD/MM/YYYY
      RegExp(r'(\d{2}-\d{2}-\d{4})'), // DD-MM-YYYY
      RegExp(r'(\d{2}\s+[A-Za-z]{3,}\s+\d{4})'), // 01 Jan 1990
    ];
    for (final p in datePatterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        final found = m.group(0)!;
        // normalize to YYYY-MM-DD if possible (simple cases)
        if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(found)) {
          dob = found;
        } else if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(found)) {
          final parts = found.split('/');
          dob = '${parts[2]}-${parts[1].padLeft(2,'0')}-${parts[0].padLeft(2,'0')}';
        } else if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(found)) {
          final parts = found.split('-');
          dob = '${parts[2]}-${parts[1].padLeft(2,'0')}-${parts[0].padLeft(2,'0')}';
        } else {
          // fallback: keep raw
          dob = found;
        }
        break;
      }
    }

    // 2) try find lines that mention name keywords
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();

      // Fullname
      if (line.contains('nom')) {
        // Nom sur ligne suivante
        final lastName = (i + 1 < lines.length) ? lines[i + 1] : '';
        // Chercher Prénom(s) aussi
        final prenomIndex = lines.indexWhere((l) => l.toLowerCase().contains('prénom'));
        final firstName = (prenomIndex != -1 && prenomIndex + 1 < lines.length) ? lines[prenomIndex + 1] : '';
        name = '$lastName $firstName'.trim();
      }
    }

    // fallback: maybe first non-empty line with letters only is name
    if (name.isEmpty) {
      for (final line in lines) {
        final cleaned = line.replaceAll(RegExp(r'[^A-Za-z\s\-]'), '').trim();
        if (cleaned.split(' ').length >= 2 && cleaned.length > 5) {
          name = cleaned;
          break;
        }
      }
    }

    // 3) nationality: look for "Nationality", 3-letter codes, or country names
    final natMatch = RegExp(r'Nationality[:\s]*([A-Za-z]{2,3})', caseSensitive: false).firstMatch(text);
    if (natMatch != null) {
      nationality = natMatch.group(1)!;
    } else {
      // try search for 3-letter uppercase codes in text
      final codeMatch = RegExp(r'\b[A-Z]{3}\b').firstMatch(text);
      if (codeMatch != null) nationality = codeMatch.group(0)!;
    }
    return ExtractedInfo(fullName: name, dateOfBirth: dob, nationality: nationality);
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
