import 'dart:io';
import 'package:flutter/material.dart';
import 'widgets/list_with_titles.dart';
import '../conection.dart';



class ViewDrive extends StatefulWidget {
  final String folderPath;
  final ServerConnectionManager connectionManager; // Conexión SSH

   const ViewDrive({super.key, required this.folderPath, required this.connectionManager});

  @override
  _ViewDriveState createState() => _ViewDriveState();
}

class _ViewDriveState extends State<ViewDrive> {
  late Directory directory;

  @override
  void initState() {
    super.initState();
    directory = Directory(widget.folderPath);
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
              setState(() {});
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
                            onPressed: () {},
                          ),
                          Text(
                            directory.path.split('\\').last,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
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
                  child: ListWithTitles(folderPath: directory.path, connectionManager: widget.connectionManager),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
