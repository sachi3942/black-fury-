class VehicleData {
  final double fuelPercent;
  final double lat;
  final double lng;
  final double tripDistKm;
  final double tripFuelLiters;

  const VehicleData({
    required this.fuelPercent,
    required this.lat,
    required this.lng,
    required this.tripDistKm,
    required this.tripFuelLiters,
  });

  factory VehicleData.empty() => const VehicleData(
        fuelPercent: 0,
        lat: 0,
        lng: 0,
        tripDistKm: 0,
        tripFuelLiters: 0,
      );

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return VehicleData(
      fuelPercent: _toDouble(json['fuel']),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      tripDistKm: _toDouble(json['trip_dist']),
      tripFuelLiters: _toDouble(json['trip_fuel']),
    );
  }

  bool get hasValidLocation => lat != 0 && lng != 0;
}
