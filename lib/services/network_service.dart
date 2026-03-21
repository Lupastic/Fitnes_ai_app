import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  NetworkService._() {
    // Подписываемся на изменения типа подключения
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateStatus(result);
    });
    
    // Начальная проверка
    _init();
  }

  static final NetworkService instance = NetworkService._();
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  
  // true = OFFLINE, false = ONLINE
  Stream<bool> get status => _controller.stream;

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(ConnectivityResult result) {
    // В вебе мы полагаемся на ConnectivityResult.none
    // На мобилках ConnectivityResult.none также означает отсутствие сети
    final bool isOffline = result == ConnectivityResult.none;
    debugPrint('Network Status: ${isOffline ? "OFFLINE" : "ONLINE"} ($result)');
    _controller.add(isOffline);
  }
}