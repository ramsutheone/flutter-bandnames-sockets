import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    String urlSocket = 'http://192.168.0.25:3000';

    this._socket = IO.io(
        urlSocket,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect()
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());

    // Dart client
    this._socket.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      print('Conectado por Socket');
      notifyListeners();
    });

    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      print('Desconectado del Socket Server');
      notifyListeners();
    });

    //Otro mensaje de socket
    /*
    this._socket.on('other-msg', (payload) {
      print('otro mensaje:');
      print('Nombre:' + payload['nombre']);
      print('Mensaje:' + payload['mensaje']);
      //analizo si exite el dato lo traigo sino capturo la excepción
      print(payload.containsKey('mensaje2')
          ? payload['mensaje2']
          : 'Parametro inexistente');

      //notifyListeners();
    });
    */
  }
}
