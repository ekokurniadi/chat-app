import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Komun extends StatefulWidget {
  @override
  _KomunState createState() => _KomunState();
}

class _KomunState extends State<Komun> {
  bool _isLoading = true;
  PDFDocument document;
  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromAsset('images/KOMUN.pdf');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Komun Apps",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Center(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : PDFViewer(
                  document: document,
                  lazyLoad: true,
                  enableSwipeNavigation: true,
                  scrollDirection: Axis.horizontal,
                )),
    );
  }
}
