class ServerConnectionManager {
  static final ServerConnectionManager _instance =
      ServerConnectionManager._internal();

  ServerConnectionManager._internal();

  factory ServerConnectionManager() => _instance;

  String? _currentName;
  String? _currentServer;
  int? _currentPort;
  String? _currentKey;

  void setConnection(String name, String server, int port, String key) {
    _currentName = name;
    _currentServer = server;
    _currentPort = port;
    _currentKey = key;
  }


  //Emulacio de la conexio 
  //TODO Afegir conexio
  Future<bool> connect() async {
    if (_currentServer == null || _currentPort == null || _currentKey == null) {
      throw Exception("Connection details are not set.");
    }

    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
