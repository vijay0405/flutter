import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.description,
      @required this.imageUrl,
      this.isFavorite = false,
      @required this.price,
      @required this.title});

  void _setFavValue(newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    final url = "https://shop-flutter-fec3d.firebaseio.com/userFavorites/$userId/$id.json?auth=$token";
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (err) {
      _setFavValue(oldStatus);
    }
  }
}
