import 'dart:io';
import 'package:flutter/material.dart';
import 'editable_text_field.dart';
import '../viewDrive.dart';
import 'server_control_widget.dart';
import '../conection.dart';

class ListWithTitles extends StatefulWidget {
  late String folderPath;
  final ServerConnectionManager connectionManager;
  final Function(String newPath)? onPathChanged; // Callback opcional

 ListWithTitles({
    Key? key,
    required this.folderPath,
    required this.connectionManager,
    this.onPathChanged,
  }) : super(key: key);

  @override
  ListWithTitlesState createState() => ListWithTitlesState();
}

class FileSystemEntityMock {
  final String name;
  final bool isDirectory;

  FileSystemEntityMock({required this.name, required this.isDirectory});
}

class ListWithTitlesState extends State<ListWithTitles> {
  late List<FileSystemEntityMock> filesAndFolders;
  int? _selectedIndex;
  late String actualPath;

  @override
  void initState() {
    super.initState();
    actualPath = widget.folderPath;
    _loadFiles(actualPath);
  }

  Future<void> _loadFiles(path) async {
    try {

      final remoteFiles =
          await widget.connectionManager.listFiles(path);

      setState(() {
        actualPath = path;
        filesAndFolders = remoteFiles
            .map((file) => FileSystemEntityMock(
                  name: file['name']!,
                  isDirectory: file['type'] == 'directory',
                ))
            .toList();
      });

       // Notificar al padre el cambio de ruta
    if (widget.onPathChanged != null) {
      widget.onPathChanged!(path);
    }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
    }
  }

    // Método público para recibir mensajes del padre
  void goBack(String path) {
    print('Mensaje recibido del padre: $path');
    // Aquí puedes realizar acciones según el mensaje recibido
    
      _loadFiles(path);
    
  }

  Future<void> _renameFile(FileSystemEntityMock entity, String newName) async {
    final originalPath = '${widget.folderPath}/${entity.name}';
    try {
      await widget.connectionManager.renameFile(originalPath, newName);
      _loadFiles(widget.folderPath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error renaming: $e')),
      );
    }
  }

  Future<void> _deleteFile(FileSystemEntityMock entity) async {
    final originalPath = '${widget.folderPath}/${entity.name}';
    try {
      await widget.connectionManager.deleteFile(originalPath);
      _loadFiles(widget.folderPath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting: $e')),
      );
    }
  }

  Future<void> _downloadFile(FileSystemEntityMock entity) async {
    final remotePath = '${widget.folderPath}/${entity.name}';
    final localPath = './downloads/${entity.name}';
    try {
      await widget.connectionManager.downloadFile(remotePath, localPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File downloaded: ${entity.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading: $e')),
      );
    }
  }

  Future<void> _showFileInfo(FileSystemEntityMock entity) async {
    final remotePath = '${widget.folderPath}/${entity.name}';
    try {
      final fileInfo = await widget.connectionManager.showFileInfo(remotePath);
      String permisos = fileInfo.split(' ')[0];
      String info = 'Name: ${entity.name}\n'
          'Type: ${entity.isDirectory ? 'Folder' : 'File'}\n'
          'Permissions: $permisos\n'
          'Size: ${fileInfo.split(' ')[4]} bytes\n'
          'Modified: ${fileInfo.split(' ')[5]} ${fileInfo.split(' ')[6]} ${fileInfo.split(' ')[7]}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(info)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error showing info: $e')),
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
            bool isServer = _isServerFolder(entity);
            if (isServer) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServerControlWidget(
                    folderPath: '${widget.folderPath}/${entity.name}',
                    onServerStateChanged: (serverInfo) {
                      // Captura el mensaje del estado del servidor
                      print('Estado del servidor: $serverInfo');
                      // Aquí puedes realizar otras acciones según la información capturada
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Servidor actualizado: $serverInfo')),
                      );
                    },
                    connectionManager: widget.connectionManager,
                  ),
                ),
              );
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          onDoubleTap: () {
            if (entity.isDirectory) {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ListWithTitles(
              //       folderPath: '${widget.folderPath}/${entity.name}',
              //       connectionManager: widget.connectionManager,
              //     ),
              //   ),
              // );
               final folderPath = '${widget.folderPath}/${entity.name}';
              _loadFiles(folderPath);
            }
          },
          child: Material(
            child: ListTile(
              leading: Icon(
                entity.isDirectory ? Icons.folder : Icons.insert_drive_file,
              ),
              title: EditableTextField(
                title: entity.name,
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
                          onPressed: () => _downloadFile(entity),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () => _showFileInfo(entity),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteFile(entity),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  bool _isServerFolder(FileSystemEntityMock entity) {
    final folderName = entity.name.toLowerCase();
    return folderName.contains('nodejs') || folderName.contains('java');
  }
}
