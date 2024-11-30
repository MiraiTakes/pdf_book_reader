import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'reader.dart'; // Импортируем ваш экран просмотра PDF

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  List<String> _books = [];
  String? _selectedFilePath; // Переменная для хранения пути к файлу

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = directory.listSync();
    final List<String> books = entities
        .where((entity) => entity is File && entity.path.endsWith('.pdf'))
        .map((entity) => entity.path)
        .toList();
    
    setState(() {
      _books = books;
    });
  }

  Future<void> _pickBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      final directory = await getApplicationDocumentsDirectory();
      final newFile = File('${directory.path}/${result.files.single.name}');
      await File(filePath).copy(newFile.path);
      setState(() {
        _selectedFilePath = newFile.path;
      });
      _loadBooks();
    }
  }

  Future<void> _deleteBook(String bookPath) async {
    final file = File(bookPath);
    if (await file.exists()) {
      await file.delete();
      _loadBooks();
    }
  }

  Future<void> _confirmDeleteBook(BuildContext context, String bookPath) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this book?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBook(bookPath);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _pickBook,
          ),
        ],
      ),
      body: _books.isNotEmpty
          ? ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final bookPath = _books[index];
                return ListTile(
                  title: Text(bookPath.split('\\').last),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _confirmDeleteBook(context, bookPath);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _selectedFilePath = bookPath;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFBookView(filePath: bookPath),
                      ),
                    );
                  },
                );
              },
            )
          : Center(child: Text('No books loaded')),
    );
  }
}