import 'package:flutter/material.dart';
import '../conection.dart';

class ServerControlWidget extends StatefulWidget {
  final String folderPath;
  final void Function(Map<String, dynamic> serverInfo) onServerStateChanged;
  final ServerConnectionManager connectionManager;

  const ServerControlWidget({
    required this.folderPath,
    required this.onServerStateChanged,
    required this.connectionManager,
    Key? key,
  }) : super(key: key);

  @override
  _ServerControlWidgetState createState() => _ServerControlWidgetState();
}

class _ServerControlWidgetState extends State<ServerControlWidget> {
  bool _isServerRunning = false; // Simulamos el estado del servidor

  Future<String> _detectServerType() async {
    final remotePath = widget.folderPath;

    try {
      // Obtén la lista de archivos del directorio remoto usando la clase connectionManager
      final files = await widget.connectionManager.listFiles(remotePath);

      // Verifica si existe 'package.json' para Node.js
      if (files.any((file) => file['name'] == 'package.json')) {
        return 'Node.js';
      }

      // Verifica si existe 'pom.xml' para Java
      if (files.any((file) => file['name'] == 'pom.xml')) {
        return 'Java';
      }

      // Si no se detecta nada, retorna 'Unknown'
      return 'Unknown';
    } catch (e) {
      print('Error detecting server type: $e');
      return 'Unknown';
    }
  }

  // Función para notificar el cambio de estado al padre
  void _notifyParent() async {
    final serverType = await _detectServerType();
    widget.onServerStateChanged({
      'isServer': serverType != 'Unknown',
      'type': serverType,
      'active': _isServerRunning,
    });
  }

  // Función para iniciar el servidor
  void startServer() {
    setState(() {
      _isServerRunning = true;
    });
    _notifyParent();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciando servidor...')),
    );
    // Aquí puedes añadir la lógica real para iniciar el servidor (por ejemplo, usando Process.start).
  }

  // Función para reiniciar el servidor
  void restartServer() {
    setState(() {
      _isServerRunning = true;
    });
    _notifyParent();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reiniciando servidor...')),
    );
    // Aquí puedes añadir la lógica real para reiniciar el servidor.
  }

  // Función para detener el servidor
  void stopServer() {
    setState(() {
      _isServerRunning = false;
    });
    _notifyParent();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deteniendo servidor...')),
    );
    // Aquí puedes añadir la lógica real para detener el servidor.
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _detectServerType(),
      builder: (context, snapshot) {
        final serverType = snapshot.data ?? 'Detectando...';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Servidor encontrado: $serverType',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (serverType != 'Unknown') ...[
              // Si el servidor está en ejecución, mostramos las opciones de reiniciar o detener.
              if (_isServerRunning) ...[
                ElevatedButton(
                  onPressed: restartServer,
                  child: const Text('Reiniciar servidor'),
                ),
                ElevatedButton(
                  onPressed: stopServer,
                  child: const Text('Detener servidor'),
                ),
              ] else ...[
                // Si el servidor no está en ejecución, mostramos el botón de iniciar.
                ElevatedButton(
                  onPressed: startServer,
                  child: const Text('Iniciar servidor'),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}
