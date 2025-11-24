import 'package:flutter/material.dart';

class DocumentScannerPage extends StatelessWidget {
  const DocumentScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF121317),
        elevation: 0,
        title: const Text('Document Scanner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.document_scanner_outlined,
                size: 120,
                color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
              ),
              const SizedBox(height: 32),
              Text(
                'Document Scanner',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF121317),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan and analyze legal documents with AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
