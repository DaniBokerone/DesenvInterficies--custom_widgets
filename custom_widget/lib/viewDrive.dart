import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'conection.dart';
import 'widgets/list_with_titles.dart';

class ViewDrive extends StatefulWidget {
  final String folderPath;
  final ServerConnectionManager connectionManager; // Conexión SSH

  const ViewDrive(
      {super.key, required this.folderPath, required this.connectionManager});

  @override
  _ViewDriveState createState() => _ViewDriveState();
}

class _ViewDriveState extends State<ViewDrive> {
  late Directory directory;
  final GlobalKey<ListWithTitlesState> _listKey =
      GlobalKey<ListWithTitlesState>();

  @override
  void initState() {
    super.initState();
    directory = Directory(widget.folderPath);
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        final localPath = result.files.single.path!;
        final fileName = result.files.single.name;
        final remotePath = '${widget.folderPath}/$fileName';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pujant arxiu...')),
        );

        await widget.connectionManager.uploadFile(localPath, remotePath);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitxer pujat amb exit!')),
        );

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pujant el arxiu: $e')),
      );
    }
  }

  void sendMessageToChild(String path) {
    if (_listKey.currentState != null) {
      print('Enviando goBack al hijo con path: $path');
      _listKey.currentState!.goBack(path); // Llamar al método del hijo
    } else {
      print('El estado del hijo aún no está listo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proxmox Drive - ${directory.path.split('\\').last}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Simplemente recargar la vista si es necesario
              // home/super/carpeta_test  ***********
              final path = '${_listKey.currentState!.actualPath.split('/')[0]}/${_listKey.currentState!.actualPath.split('/')[1]}';
              print(path);
              sendMessageToChild(path);
            },
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () {
              // Acción para apagado, o lo que sea necesario
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel: Sidebar
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Recents'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Carpetes'),
                  selected: true,
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Eliminats'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),

          // Right Panel: File Explorer
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              // Volver a la carpeta padre
                              final parentPath = directory.parent.path;
                              setState(() {
                                directory = Directory(parentPath);
                              });
                              sendMessageToChild(parentPath);
                            },
                          ),
                          Text(
                            directory.path.split('\\').last,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _pickAndUploadFile,
                        child: const Text('Afegir arxius'),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Ordenar segons: Nom',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ),
                const Divider(),

                // File and Folder List
                Expanded(
                  // child: Builder(
                  //   builder: (context) {
                  //     return ListWithTitles(
                  //       key: _listKey, // Asignar el GlobalKey aquí
                  //       folderPath: directory.path,
                  //       connectionManager: widget.connectionManager,
                  //     );

                  child: ListWithTitles(
                    key: _listKey, // Asignar el GlobalKey aquí
                    folderPath: directory.path,
                    connectionManager: widget.connectionManager,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
