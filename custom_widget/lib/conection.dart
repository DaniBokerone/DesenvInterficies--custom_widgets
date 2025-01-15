import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';

class ServerConnectionManager {
  static final ServerConnectionManager _instance =
      ServerConnectionManager._internal();

  ServerConnectionManager._internal();

  factory ServerConnectionManager() => _instance;

  String? _currentUsername;
  String? _currentServer;
  int? _currentPort;
  String? _currentPrivateKeyPath;

  SSHClient? _sshClient;
  

  void setConnection(String username, String server, int port, String privateKeyPath) {
    _currentUsername = username;
    _currentServer = server;
    _currentPort = port;
    _currentPrivateKeyPath = privateKeyPath;

    print("Connection details set:");
    print("Username: $_currentUsername, Server: $_currentServer, Port: $_currentPort");
  }

  Future<void> connect() async {
    if (_currentServer == null || _currentPort == null || _currentUsername == null || _currentPrivateKeyPath == null) {
      throw Exception("Connection details are not set.");
    }

    try {
      final socket = await SSHSocket.connect(_currentServer!, _currentPort!);

      final privateKeyPem = await File(_currentPrivateKeyPath!).readAsString();

      _sshClient = SSHClient(
        socket,
        username: _currentUsername!,
        identities: [
          ...SSHKeyPair.fromPem(privateKeyPem),
        ],
      );

      print("Successfully connected to $_currentServer on port $_currentPort.");
    } catch (e) {
      print("Error while connecting: $e");
      throw Exception("Failed to connect to the SSH server: $e");
    }
  }

  /// Ejecutar un comando en el servidor SSH.
  Future<String> executeCommand(String command) async {
    if (_sshClient == null) {
      throw Exception("SSH Client is not initialized. Call connect() first.");
    }

    try {
      final result = await _sshClient!.run(command);
      final output = utf8.decode(result);
      print("Command output: $output");
      return output;
    } catch (e) {
      print("Error while executing command: $e");
      throw Exception("Failed to execute command: $e");
    }
  }

  /// Cerrar la conexión SSH.
  Future<void> disconnect() async {
    if (_sshClient != null) {
      _sshClient!.close();

      await _sshClient!.done;

      _sshClient = null;
      print("Disconnected from the SSH server.");
    } else {
      print("No SSH client to disconnect.");
    }
  }
}
