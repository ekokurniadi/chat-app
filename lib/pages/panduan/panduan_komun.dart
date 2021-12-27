import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PanduanKomun extends StatefulWidget {
  @override
  _PanduanKomunState createState() => _PanduanKomunState();
}

class _PanduanKomunState extends State<PanduanKomun> {
  bool _isLoading = true;
  PDFDocument document;
  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromAsset('images/Panduankomun.pdf');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Terms Of Komun Apps",
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
