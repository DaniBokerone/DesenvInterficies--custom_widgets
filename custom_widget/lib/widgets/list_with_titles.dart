import 'dart:io';
import 'package:flutter/material.dart';
import 'editable_text_field.dart';
import '../viewDrive.dart';
import 'server_control_widget.dart';

class ListWithTitles extends StatefulWidget {
  final String folderPath;

  ListWithTitles({required this.folderPath});

  @override
  _ListWithTitlesState createState() => _ListWithTitlesState();
}

class _ListWithTitlesState extends State<ListWithTitles> {
  late Directory directory;
  late List<FileSystemEntity> filesAndFolders;

  @override
  void initState() {
    super.initState();
    directory = Directory(widget.folderPath);
    _loadFiles();
  }

  // Cargar los archivos y carpetas del directorio
  void _loadFiles() {
    setState(() {
      if (directory.existsSync()) {
        filesAndFolders = directory.listSync();
      } else {
        filesAndFolders = [];
      }
    });
  }

  // Renombrar un archivo o carpeta
  Future<void> _renameFile(FileSystemEntity entity, String newName) async {
    final newPath = '${directory.path}/$newName';
    print(newPath);
    try {
      if (entity is File) {
        await entity.rename(newPath);
      } else if (entity is Directory) {
        await entity.rename(newPath);
      }
      _loadFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error renaming: $e')),
      );
    }
  }

  // Eliminar un archivo o carpeta
  Future<void> _deleteFile(FileSystemEntity entity) async {
    try {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await entity.delete(recursive: true);
      }
      _loadFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filesAndFolders.length,
      itemBuilder: (context, index) {
        final entity = filesAndFolders[index];
        return ListTile(
          leading: Icon(
            entity is Directory ? Icons.folder : Icons.insert_drive_file,
          ),
          title: EditableTextField(
            title: entity.path.split('\\').last,
            onSubmit: (newName) {
              _renameFile(entity, newName);
            },
          ),
          onTap: () {
            if (entity is Directory) {
              // Verifica si la carpeta es un servidor de tipo NodeJS o Java
              bool isServer = _isServerFolder(entity);

              if (isServer) {
                // Si es un servidor, muestra el widget de control del servidor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServerControlWidget(directory: entity),
                  ),
                );
              } else {
                // Si no es un servidor, navega al explorador de archivos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewDrive(folderPath: entity.path),
                  ),
                );
              }
            }
          },
          trailing: entity is! Directory
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _deleteFile(entity);
                  },
                )
              : null,
        );
      },
    );
  }
}

bool _isServerFolder(Directory directory) {
  // Aquí verificas si la carpeta contiene archivos o características de un servidor NodeJS o Java
  final folderName = directory.path.split('/').last.toLowerCase();
  return folderName.contains('nodejs') || folderName.contains('java');
}
