import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/vehicle_data.dart';

/// Handles all communication with the Firebase Realtime Database via
/// plain REST calls (GET/PUT + `.json` + `auth` query param).
class FirebaseService {
  Timer? _pollTimer;

  final _dataController = StreamController<VehicleData>.broadcast();
  final _thiefController = StreamController<bool>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<VehicleData> get dataStream => _dataController.stream;
  Stream<bool> get thiefAlertStream => _thiefController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Starts periodic polling of vehicle data + thief-detection flag.
  void startPolling({Duration interval = AppConfig.pollInterval}) {
    _pollTimer?.cancel();
    _fetchAll(); // immediate first fetch
    _pollTimer = Timer.periodic(interval, (_) => _fetchAll());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchVehicleData(),
      _fetchThiefFlag(),
    ]);
  }

  Future<void> _fetchVehicleData() async {
    try {
      final res = await http
          .get(Uri.parse(AppConfig.vehicleDataUrl))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200 && res.body != 'null') {
        final Map<String, dynamic> json =
            jsonDecode(res.body) as Map<String, dynamic>;
        _dataController.add(VehicleData.fromJson(json));
        _connectionController.add(true);
      } else {
        _connectionController.add(false);
      }
    } catch (_) {
      _connectionController.add(false);
    }
  }

  Future<void> _fetchThiefFlag() async {
    try {
      final res = await http
          .get(Uri.parse(AppConfig.isThiefUrl))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = res.body.trim();
        final value = int.tryParse(body) ?? 0;
        _thiefController.add(value == 1);
      }
    } catch (_) {
      // Silently ignore transient errors on this channel; the main
      // connection indicator already reflects overall health.
    }
  }

  /// Sends the relay control command.
  /// [locked] = true  -> writes 1 (Lock)
  /// [locked] = false -> writes 0 (Unlock)
  Future<bool> setRelay({required bool locked}) async {
    try {
      final res = await http
          .put(
            Uri.parse(AppConfig.relayControlUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(locked ? 1 : 0),
          )
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Clears the thief-alert flag on the backend once acknowledged.
  Future<void> clearThiefAlert() async {
    try {
      await http.put(
        Uri.parse(AppConfig.isThiefUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(0),
      );
    } catch (_) {
      // best-effort
    }
  }

  void dispose() {
    _pollTimer?.cancel();
    _dataController.close();
    _thiefController.close();
    _connectionController.close();
  }
}
