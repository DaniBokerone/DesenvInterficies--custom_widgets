import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxmox Drive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ViewDrive(),
    );
  }
}

class ViewDrive extends StatelessWidget {
  const ViewDrive({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxmox Drive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
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
                          const Text(
                            '"carpeta A"',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  child: ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.folder),
                        title: const Text('carpeta A1'),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.folder),
                        title: const Text('treballs'),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.archive),
                        title: const Text('dades.zip'),
                        trailing: Row(
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
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.description),
                        title: const Text('biblio.json'),
                        trailing: Row(
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
                        ),
                      ),
                    ],
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
