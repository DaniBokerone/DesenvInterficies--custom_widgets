import 'dart:io';
import 'package:flutter/material.dart';
import 'editable_text_field.dart';
import '../viewDrive.dart';
import 'server_control_widget.dart';
import '../conection.dart';

class ListWithTitles extends StatefulWidget {
  final String folderPath;
  final ServerConnectionManager connectionManager;

  ListWithTitles({required this.folderPath, required this.connectionManager});

  @override
  _ListWithTitlesState createState() => _ListWithTitlesState();
}

class FileSystemEntityMock {
  final String name;
  final bool isDirectory;

  FileSystemEntityMock({required this.name, required this.isDirectory});
}

class _ListWithTitlesState extends State<ListWithTitles> {
  late Directory directory;
  late List<FileSystemEntityMock>
      filesAndFolders; // Cambiar a FileSystemEntityMock
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    directory = Directory(widget.folderPath);
    _loadFiles();
  }

 Future<void> _loadFiles() async {
    try {
      // Llama al método listFiles de connectionManager para obtener los archivos remotos
      final remoteFiles = await widget.connectionManager.listFiles(widget.folderPath);

      setState(() {
        // Convierte los archivos remotos en un formato adecuado para mostrarlos
        filesAndFolders = remoteFiles
            .map((file) => FileSystemEntityMock(
                  name: file['name']!,
                  isDirectory: file['type'] == 'directory',
                ))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
    }
  }


  // Renombrar un archivo o carpeta
  Future<void> _renameFile(FileSystemEntityMock entity, String newName) async {
    final newPath = '${directory.path}/$newName';
    print(newPath);
    try {
     // Para renombrar un archivo
      await widget.connectionManager.renameFile(newPath, newName);
      _loadFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error renaming: $e')),
      );
    }
  }

  // Eliminar un archivo o carpeta
  Future<void> _deleteFile(FileSystemEntityMock entity) async {
    try {
      // Aquí debes manejar la eliminación de los archivos en el servidor remoto
      // Implementa la lógica para eliminar en el servidor utilizando connectionManager o una librería adecuada.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo o carpeta eliminada: ${entity.name}')),
      );
      _loadFiles(); // Actualiza la lista después de eliminar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando: $e')),
      );
    }
  }

  void _downloadFile(FileSystemEntityMock entity) async {
    try {
      // Simula la lógica de descarga de un archivo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Descargando archivo: ${entity.name}')),
      );
      // Aquí puedes implementar la lógica real de descarga,
      // como copiar el archivo a otra ubicación o subirlo a un servidor.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error descargando: $e')),
      );
    }
  }

  void _showFileInfo(FileSystemEntityMock entity) {
    try {
      String info = '';
      info = 'Nombre: ${entity.name}\n'
          'Tipo: ${entity.isDirectory ? 'Carpeta' : 'Archivo'}';
      // Mostrar la información en un SnackBar o cualquier otro widget
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(info)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mostrando información: $e')),
      );
    }
  

  // ********************************************
 

// // Para eliminar un archivo
// await connectionManager.deleteFile('/ruta/remota/archivo.txt');

// // Para descargar un archivo
// await connectionManager.downloadFile('/ruta/remota/archivo.txt', '/ruta/local/archivo.txt');

// // Para mostrar información de un archivo
// final fileInfo = await connectionManager.showFileInfo('/ruta/remota/archivo.txt');
// print(fileInfo);
// ********************************************
}
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filesAndFolders.length,
      itemBuilder: (context, index) {
        final entity = filesAndFolders[index];
        final isSelected = _selectedIndex == index;

        return GestureDetector(
          onTap: () {
            // Verifica si la carpeta es un servidor de tipo NodeJS o Java
            bool isServer = _isServerFolder(entity);
            if (isServer) {
              // Si es un servidor, muestra el widget de control del servidor
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServerControlWidget(
                      directory:
                          Directory('${widget.folderPath}/${entity.name}')),
                ),
              );
            } else {
              setState(() {
                _selectedIndex =
                    index; // Actualiza el índice del elemento seleccionado
              });
            }
          },
          onDoubleTap: () {
            if (entity.isDirectory) {
              // Si es una carpeta, navega a la vista de la carpeta
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListWithTitles(
                    folderPath: '${widget.folderPath}/${entity.name}',
                    connectionManager: widget.connectionManager,
                  ),
                ),
              );
            }
          },
          child: ListTile(
            leading: Icon(
              entity.isDirectory ? Icons.folder : Icons.insert_drive_file,
            ),
            title: EditableTextField(
              title: entity.name,
              onSubmit: (newName) {
                // Lógica para renombrar (puedes adaptarla según tus necesidades)
                _renameFile(entity, newName);
              },
            ),
            trailing: isSelected
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          // Lógica de descarga
                          _downloadFile(entity);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.info),
                        onPressed: () {
                          // Lógica para mostrar información
                          _showFileInfo(entity);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _deleteFile(entity);
                        },
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  bool _isServerFolder(FileSystemEntityMock entity) {
    // Aquí verificas si la carpeta contiene archivos o características de un servidor NodeJS o Java
    final folderName = entity.name.toLowerCase();
    return folderName.contains('nodejs') || folderName.contains('java');
  }
}
