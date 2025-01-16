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
  int? _selectedIndex;

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

// void _loadFiles() async {
//   try {
//     final sshManager = SSHManager();

//     // Cambia esta ruta al directorio remoto deseado
//     final remotePath = widget.folderPath;

//     // Llama al método listFiles del singleton
//     final remoteFiles = await sshManager.listFiles(remotePath);

//     setState(() {
//       // Convierte los archivos remotos en un formato adecuado para mostrarlos
//       filesAndFolders = remoteFiles
//           .map((file) => FileSystemEntityMock(
//                 name: file['name']!,
//                 isDirectory: file['type'] == 'directory',
//               ))
//           .toList();
//     });
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error loading files: $e')),
//     );
//   }
// }


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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo eliminado: ${entity.path}')),
        );
      } else if (entity is Directory) {
        await entity.delete(recursive: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Carpeta eliminada: ${entity.path}')),
        );
      }
      _loadFiles(); // Actualiza la lista después de eliminar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando: $e')),
      );
    }
  }

  void _downloadFile(FileSystemEntity entity) async {
    try {
      if (entity is File) {
        // Simula la lógica de descarga de un archivo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Descargando archivo: ${entity.path}')),
        );
        // Aquí puedes implementar la lógica real de descarga,
        // como copiar el archivo a otra ubicación o subirlo a un servidor.
      } else if (entity is Directory) {
        // Simula la lógica de descarga de una carpeta
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Descargando carpeta: ${entity.path}')),
        );
        // Implementa la lógica para manejar la descarga de carpetas.
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error descargando: $e')),
      );
    }
  }

  void _showFileInfo(FileSystemEntity entity) {
    try {
      String info = '';

      if (entity is File) {
        // Obtener información del archivo
        final fileSize = entity.lengthSync(); // Tamaño del archivo
        final lastModified =
            entity.lastModifiedSync(); // Fecha de última modificación
        info = 'Archivo: ${entity.path}\n'
            'Tamaño: ${fileSize} bytes\n'
            'Última modificación: $lastModified';
      } else if (entity is Directory) {
        // Obtener información de la carpeta
        final contentCount =
            entity.listSync().length; // Número de elementos dentro
        info = 'Carpeta: ${entity.path}\n'
            'Elementos: $contentCount\n';
      }

      // Mostrar la información en un SnackBar o cualquier otro widget
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(info)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mostrando información: $e')),
      );
    }
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
              directory = entity as Directory;
              // Si es un servidor, muestra el widget de control del servidor ********
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServerControlWidget(directory: entity),
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
            if (entity is Directory) {
              // Si es una carpeta, navega a la vista de la carpeta
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewDrive(folderPath: entity.path),
                ),
              );
            }
          },
          child: ListTile(
            leading: Icon(
              entity is Directory ? Icons.folder : Icons.insert_drive_file,
            ),
            title: EditableTextField(
              title: entity.path.split('\\').last,
              onSubmit: (newName) {
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
}

bool _isServerFolder(FileSystemEntity entity) {
  // Aquí verificas si la carpeta contiene archivos o características de un servidor NodeJS o Java
  if (entity is Directory) {
    final folderName = entity.path.split('/').last.toLowerCase();
    return folderName.contains('nodejs') || folderName.contains('java');
  }
  return false;
}
