import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Widgets Example')),
        body: const WidgetsExample(),
      ),
    );
  }
}

class WidgetsExample extends StatelessWidget {
  const WidgetsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleIndicator(isActive: true),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          const PortRedirectWidget(),
          const SizedBox(height: 20),
          const ServerStatusWidget(status: "running"),
        ],
      ),
    );
  }
}


// 2. Widget que muestra un círculo verde o rojo según un booleano
class CircleIndicator extends StatelessWidget {
  final bool isActive;

  const CircleIndicator({required this.isActive, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}


// 4. Widget para configurar redirecciones del puerto 80 a otro puerto
class PortRedirectWidget extends StatefulWidget {
  const PortRedirectWidget({super.key});

  @override
  _PortRedirectWidgetState createState() => _PortRedirectWidgetState();
}

class _PortRedirectWidgetState extends State<PortRedirectWidget> {
  bool isRedirecting = false;
  String redirectPort = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text("Redirect Port 80"),
          value: isRedirecting,
          onChanged: (value) {
            setState(() {
              isRedirecting = value;
            });
          },
        ),
        if (isRedirecting)
          TextField(
            decoration: const InputDecoration(
              labelText: "Target Port",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                redirectPort = value;
              });
            },
          ),
      ],
    );
  }
}

// 5. Widget que muestra el estado de un servidor
class ServerStatusWidget extends StatelessWidget {
  final String status;

  const ServerStatusWidget({required this.status, super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case "running":
        return Colors.green;
      case "stopped":
        return Colors.red;
      case "restarting":
        return Colors.orange;
      case "error":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "Status: $status",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
