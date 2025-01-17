import 'dart:io';
import 'package:flutter/material.dart';

class ServerControlWidget extends StatefulWidget {
  final Directory directory;
  final void Function(Map<String, dynamic> serverInfo) onServerStateChanged;

  const ServerControlWidget({
    required this.directory,
    required this.onServerStateChanged,
    Key? key,
  }) : super(key: key);

  @override
  _ServerControlWidgetState createState() => _ServerControlWidgetState();
}

class _ServerControlWidgetState extends State<ServerControlWidget> {
  bool _isServerRunning = false; // Simulamos el estado del servidor

  // Función para verificar si es un servidor Node.js o Java
  String _detectServerType() {
    if (widget.directory.listSync().any((entity) =>
        entity is File && entity.path.endsWith('package.json'))) {
      return 'Node.js';
    } else if (widget.directory.listSync().any((entity) =>
        entity is File && entity.path.endsWith('pom.xml'))) {
      return 'Java';
    } else {
      return 'Unknown';
    }
  }

  // Función para notificar el cambio de estado al padre
  void _notifyParent() {
    final serverType = _detectServerType();
    widget.onServerStateChanged({
      'isServer': serverType != 'Unknown',
      'type': serverType,
      'active': _isServerRunning,
    });
  }

  // Función para iniciar el servidor
  void _startServer() {
    setState(() {
      _isServerRunning = true;
    });
    _notifyParent();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Iniciando servidor...')),
    );
    // Aquí puedes añadir la lógica real para iniciar el servidor (por ejemplo, usando Process.start).
  }

  // Función para reiniciar el servidor
  void _restartServer() {
    setState(() {
      _isServerRunning = true;
    });
    _notifyParent();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reiniciando servidor...')),
    );
    // Aquí puedes añadir la lógica real para reiniciar el servidor.
  }

  // Función para detener el servidor
  void _stopServer() {
    setState(() {
      _isServerRunning = false;
    });
    _notifyParent();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deteniendo servidor...')),
    );
    // Aquí puedes añadir la lógica real para detener el servidor.
  }

  @override
  Widget build(BuildContext context) {
    String serverType = _detectServerType();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servidor encontrado: $serverType',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        if (serverType != 'Unknown') ...[
          // Si el servidor está en ejecución, mostramos las opciones de reiniciar o detener.
          if (_isServerRunning) ...[
            ElevatedButton(
              onPressed: _restartServer,
              child: Text('Reiniciar servidor'),
            ),
            ElevatedButton(
              onPressed: _stopServer,
              child: Text('Detener servidor'),
            ),
          ] else ...[
            // Si el servidor no está en ejecución, mostramos el botón de iniciar.
            ElevatedButton(
              onPressed: _startServer,
              child: Text('Iniciar servidor'),
            ),
          ],
        ]
      ],
    );
  }
}
