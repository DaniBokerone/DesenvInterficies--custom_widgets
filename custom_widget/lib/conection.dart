import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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

  void setConnection(
      String username, String server, int port, String privateKeyPath) {
    _currentUsername = username;
    _currentServer = server;
    _currentPort = port;
    _currentPrivateKeyPath = privateKeyPath;

    print("Connection details set:");
    print(
        "Username: $_currentUsername, Server: $_currentServer, Port: $_currentPort");
  }

  Future<void> connect() async {
    if (_currentServer == null ||
        _currentPort == null ||
        _currentUsername == null ||
        _currentPrivateKeyPath == null) {
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

  /// Método para listar archivos y directorios remotos
  Future<List<Map<String, String>>> listFiles(String remotePath) async {
    try {
      // Ejecuta el comando 'ls -l' en el servidor SSH
      final result = await executeCommand('ls -l $remotePath');

      final files = <Map<String, String>>[];

      // Procesa cada línea de la salida
      for (var line in result.split('\n')) {
        if (line.isNotEmpty) {
          final parts = line.split(RegExp(r'\s+'));
          final isDirectory = parts[0].startsWith('d'); // 'd' indica directorio
          final name = parts.last;

          // Añade el archivo o directorio a la lista
          files.add({
            'name': name,
            'type': isDirectory ? 'directory' : 'file',
          });
        }
      }

      return files;
    } catch (e) {
      print("Error while listing files: $e");
      throw Exception("Error listing files: $e");
    }
  }

  Future<void> renameFile(String remotePath, String newName) async {
    try {
      // Usamos el comando 'mv' para renombrar el archivo o carpeta
      final command = 'mv $remotePath $newName';
      await executeCommand(command);
      print("Archivo o carpeta renombrado a: $newName");
    } catch (e) {
      print("Error renombrando archivo o carpeta: $e");
      throw Exception("Error renombrando archivo o carpeta: $e");
    }
  }

  Future<void> deleteFile(String remotePath) async {
    try {
      // Usamos el comando 'rm' para eliminar el archivo o 'rm -r' para eliminar un directorio
      final command = remotePath.endsWith('/')
          ? 'rm -r $remotePath' // Si es un directorio
          : 'rm $remotePath'; // Si es un archivo
      await executeCommand(command);
      print("Archivo o carpeta eliminada: $remotePath");
    } catch (e) {
      print("Error eliminando archivo o carpeta: $e");
      throw Exception("Error eliminando archivo o carpeta: $e");
    }
  }

  Future<void> downloadFile(String remotePath, String localPath) async {
    try {
      // Simulamos la descarga de un archivo desde el servidor
      print("Descargando archivo desde: $remotePath a $localPath");

      // Aquí puedes implementar la lógica real de descarga,
      // como usar 'scp' o descargar el archivo usando un paquete adicional de Dart.
    } catch (e) {
      print("Error descargando archivo: $e");
      throw Exception("Error descargando archivo: $e");
    }
  }

  Future<String> showFileInfo(String remotePath) async {
  try {
    // Usamos el comando 'ls -l' para obtener detalles del archivo o carpeta
    final result = await executeCommand('ls -l $remotePath');
    print("Información del archivo o carpeta: $result");
    return result;
  } catch (e) {
    print("Error mostrando información del archivo o carpeta: $e");
    throw Exception("Error mostrando información del archivo o carpeta: $e");
  }
}

Future<void> uploadFile(String localPath, String remotePath) async {
  if (_sshClient == null) {
    throw Exception("SSH Client is not initialized. Call connect() first.");
  }

  try {
    final sftp = await _sshClient!.sftp();

    final file = File(localPath);

    if (!file.existsSync()) {
      throw Exception("No existeix l'arxiu local: $localPath");
    }

    final sanitizedRemotePath = remotePath.replaceAll(' ', '_');

    final fileStream = file.openRead().map((chunk) => Uint8List.fromList(chunk));

    final remoteFile = await sftp.open(
      sanitizedRemotePath,
      mode: SftpFileOpenMode.create | SftpFileOpenMode.write,
    );

    await remoteFile.write(fileStream);
    await remoteFile.close();
    sftp.close();

    print("Arxiu p: $sanitizedRemotePath");
  } catch (e) {
    print("Error al pujar el arxiu: $e");
    throw Exception("Error al pujar el arxiu: $e");
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
