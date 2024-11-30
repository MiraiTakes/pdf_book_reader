import 'dart:io';
import 'package:book_reader/library.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFBookView extends StatefulWidget {
  final String filePath;
  PDFBookView({required this.filePath});

  @override
  _PDFBookViewState createState() => _PDFBookViewState();
}

class _PDFBookViewState extends State<PDFBookView> {
  late PdfViewerController _pdfViewerController1;
  late PdfViewerController _pdfViewerController2;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey1 = GlobalKey();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey2 = GlobalKey();
  int _currentPage = 1;
  int _numPages = 0;
  bool _isSynchronizing = false;
  late PdfDocument _pdfDocument;

  @override
  void initState() {
    super.initState();
    _pdfViewerController1 = PdfViewerController();
    _pdfViewerController2 = PdfViewerController();

    _pdfViewerController1.addListener(_onPageChanged1);
    _pdfViewerController2.addListener(_onPageChanged2);

    _loadDocument();
  }

  void _loadDocument() async {
    _pdfDocument = PdfDocument(inputBytes: File(widget.filePath).readAsBytesSync());
    setState(() {
      _numPages = _pdfDocument.pages.count;
    });
  }

  void _onPageChanged1() {
    if (_isSynchronizing) return;
    _isSynchronizing = true;
    final newPage = _pdfViewerController1.pageNumber;
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
      _pdfViewerController2.jumpToPage(_currentPage + 1);
    }
    _isSynchronizing = false;
  }

  void _onPageChanged2() {
    if (_isSynchronizing) return;
    _isSynchronizing = true;
    final newPage = _pdfViewerController2.pageNumber;
    if (newPage - 1 != _currentPage) {
      setState(() {
        _currentPage = newPage - 1;
      });
      _pdfViewerController1.jumpToPage(_currentPage);
    }
    _isSynchronizing = false;
  }

  void _nextPage() {
    if (_currentPage + 2 <= _numPages) {
      setState(() {
        _currentPage += 2;
      });
      _isSynchronizing = true;
      _pdfViewerController1.jumpToPage(_currentPage);
      _pdfViewerController2.jumpToPage(_currentPage + 1);
      _isSynchronizing = false;
    }
  }

  void _previousPage() {
    if (_currentPage - 2 > 0) {
      setState(() {
        _currentPage -= 2;
      });
      _isSynchronizing = true;
      _pdfViewerController1.jumpToPage(_currentPage);
      _pdfViewerController2.jumpToPage(_currentPage + 1);
      _isSynchronizing = false;
    }
  }

  @override
  void dispose() {
    _pdfViewerController1.removeListener(_onPageChanged1);
    _pdfViewerController2.removeListener(_onPageChanged2);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _numPages > 0
          ? Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousPage,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2 - 65,
                  height: MediaQuery.of(context).size.height,
                  child: SfPdfViewer.file(
                    File(widget.filePath),
                    controller: _pdfViewerController1,
                    pageLayoutMode: PdfPageLayoutMode.single,
                    initialZoomLevel: 1,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2 - 65,
                  height: MediaQuery.of(context).size.height,
                  child: SfPdfViewer.file(
                    File(widget.filePath),
                    key: _pdfViewerKey1,
                    controller: _pdfViewerController2,
                    pageLayoutMode: PdfPageLayoutMode.single,
                    initialZoomLevel: 1,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextPage,
                ),
                Container(
                  width: 50,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.blueGrey),
                    ),
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          _pdfViewerKey1.currentState?.openBookmarkView();
                        },
                        icon: Icon(Icons.bookmark),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push( context, MaterialPageRoute(builder: (context) => Library()), );
                        },
                        icon: Icon(Icons.library_books),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
