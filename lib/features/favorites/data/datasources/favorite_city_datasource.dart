import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/favorite_city_model.dart';

class FavoriteCityDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FavoriteCityDatasource(this.firestore, this.auth);

  String get _userId => auth.currentUser?.uid ?? '';

  // Lấy stream danh sách từ Firestore
  Stream<List<FavoriteCityModel>> streamFavoriteCities() {
    return firestore
        .collection('users')
        .doc(_userId)
        .collection('favorite_cities')
        .snapshots()
        .map(
          (q) => q.docs
              .map((doc) => FavoriteCityModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Thêm thành phố yêu thích - Cập nhật cả Firestore và SharedPreferences
  Future<void> addFavoriteCity(FavoriteCityModel city) async {
    await firestore
        .collection('users')
        .doc(_userId)
        .collection('favorite_cities')
        .doc(city.name)
        .set(city.toJson());

    // --- Lưu xuống SharedPreferences để sử dụng cho weather_map_page ---
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favoriteLocationsWithLatLng') ?? [];
    // Kiểm tra trùng, xóa entry cũ nếu có
    favorites.removeWhere((item) {
      final data = jsonDecode(item);
      return data['name'] == city.name;
    });
    favorites.add(jsonEncode(city.toJson()));
    await prefs.setStringList('favoriteLocationsWithLatLng', favorites);
  }

  // Xóa thành phố khỏi Firestore và local SP
  Future<void> removeFavoriteCity(String cityName) async {
    await firestore
        .collection('users')
        .doc(_userId)
        .collection('favorite_cities')
        .doc(cityName)
        .delete();

    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favoriteLocationsWithLatLng') ?? [];
    favorites.removeWhere((item) {
      final data = jsonDecode(item);
      return data['name'] == cityName;
    });
    await prefs.setStringList('favoriteLocationsWithLatLng', favorites);
  }
}
