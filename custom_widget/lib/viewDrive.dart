import 'dart:io';
import 'package:flutter/material.dart';


class ViewDrive extends StatefulWidget {
  final String folderPath;

  const ViewDrive({super.key, required this.folderPath});

  @override
  _ViewDriveState createState() => _ViewDriveState();
}

class _ViewDriveState extends State<ViewDrive> {
  late Directory directory;
  late List<FileSystemEntity> filesAndFolders;

  @override
  void initState() {
    super.initState();
    directory = Directory(widget.folderPath);
    print(widget.folderPath);
    _loadFiles();
  }

  void _loadFiles() {
    if (directory.existsSync()) {
      setState(() {
        filesAndFolders = directory.listSync();
      });
      
    } else {
      setState(() {
        filesAndFolders = [];
      });
    }

    print(filesAndFolders);
  }

  IconData _getIconForFile(FileSystemEntity entity) {
    if (entity is Directory) {
      return Icons.folder;
    } else if (entity is File) {
      String extension = entity.path.split('.').last.toLowerCase();
      switch (extension) {
        case 'zip':
          return Icons.archive;
        case 'json':
          return Icons.description;
        default:
          return Icons.insert_drive_file;
      }
    }
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proxmox Drive - ${directory.path.split('/').last}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () {},
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
                            directory.path.split('/').last,
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
                  child: ListView.builder(
                    itemCount: filesAndFolders.length,
                    itemBuilder: (context, index) {
                      final entity = filesAndFolders[index];
                      return ListTile(
                        leading: Icon(_getIconForFile(entity)),
                        title: Text(entity.path.split('/').last),
                        onTap: () {
                          if (entity is Directory) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewDrive(
                                  folderPath: entity.path,
                                ),
                              ),
                            );
                          }
                        },
                        trailing: entity is File
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.fullscreen),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {},
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
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
