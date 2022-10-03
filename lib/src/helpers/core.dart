import 'package:cloud_firestore/cloud_firestore.dart';

extension MapTimestamp on Map {
  /// Adds a key named "timestamp" for firestore
  void timestamp() {
    if (this["timestamp"] == null) {
      this["timestamp"] = Timestamp.now();
    }
  }
}
