import 'dart:convert';
import 'package:custom_widget/conection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server Connection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ServerConnectionPage(),
    );
  }
}

class ServerConnectionPage extends StatefulWidget {
  const ServerConnectionPage({super.key});

  @override
  State<ServerConnectionPage> createState() => _ServerConnectionPageState();
}

class _ServerConnectionPageState extends State<ServerConnectionPage> {
  final List<Map<String, dynamic>> _servers = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  int? _selectedServerIndex;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _saveServers() async {
    final prefs = await SharedPreferences.getInstance();
    final serversJson = json.encode(_servers);
    await prefs.setString('servers', serversJson);
  }

  Future<void> _loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final serversJson = prefs.getString('servers');
    if (serversJson != null) {
      setState(() {
        _servers.addAll(List<Map<String, dynamic>>.from(json.decode(serversJson)));
      });
    }
  }

  void _addServer() {
    setState(() {
      _servers.add({
        'name': _nameController.text,
        'server': _serverController.text,
        'port': _portController.text,
        'key': _keyController.text,
        'favorite': false,
      });
      _clearInputs();
    });
    _saveServers();
  }

  void _deleteServer() {
    if (_selectedServerIndex != null) {
      setState(() {
        _servers.removeAt(_selectedServerIndex!);
        _clearInputs();
        _selectedServerIndex = null;
      });
      _saveServers();
    }
  }

  void _toggleFavorite() {
    if (_selectedServerIndex != null) {
      setState(() {
        _servers[_selectedServerIndex!]['favorite'] =
            !_servers[_selectedServerIndex!]['favorite'];
      });
      _saveServers();
    }
  }

  void _connect() async {
    if (_selectedServerIndex != null) {
      final selectedServer = _servers[_selectedServerIndex!];
      final connectionManager = ServerConnectionManager();

      connectionManager.setConnection(
        selectedServer['name'],
        selectedServer['server'],
        int.parse(selectedServer['port']),
        selectedServer['key'],
      );

      try {
        final success = await connectionManager.connect();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Connected to ${selectedServer['name']}!'
                : 'Failed to connect to ${selectedServer['name']}!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _clearInputs() {
    _nameController.clear();
    _serverController.clear();
    _portController.clear();
    _keyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Connection'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _servers.length,
              itemBuilder: (context, index) {
                final server = _servers[index];
                return ListTile(
                  title: Text(server['name']),
                  subtitle: Text('${server['server']}:${server['port']}'),
                  trailing: Icon(
                    server['favorite'] ? Icons.star : Icons.star_border,
                    color: server['favorite'] ? Colors.yellow : Colors.grey,
                  ),
                  selected: index == _selectedServerIndex,
                  onTap: () {
                    setState(() {
                      _selectedServerIndex = index;
                      _nameController.text = server['name'];
                      _serverController.text = server['server'];
                      _portController.text = server['port'];
                      _keyController.text = server['key'];
                    });
                  },
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Connection Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _serverController,
                    decoration: const InputDecoration(
                      labelText: 'Server',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      labelText: 'Connection Key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _deleteServer,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _toggleFavorite,
                        icon: const Icon(Icons.star),
                        label: const Text('Favorite'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _connect,
                        icon: const Icon(Icons.link),
                        label: const Text('Connect'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addServer,
        tooltip: 'Add Server',
        child: const Icon(Icons.add),
      ),
    );
  }
}
