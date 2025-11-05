import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../features/weather/data/datasources/weather_api_datasource.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/data/repositories/city_suggestion_repository_impl.dart';
import '../../features/weather/domain/repositories/city_suggestion_repository.dart';
import '../../features/weather/domain/usecases/get_city_suggestions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/favorites/data/datasources/favorite_city_datasource.dart';
import '../../features/favorites/data/repositories/favorite_city_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorite_city_repository.dart';
import '../../features/favorites/domain/usecases/remove_favorite_city.dart';
import '../../features/favorites/domain/usecases/add_favorite_city.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton<http.Client>(() => http.Client());

  sl.registerLazySingleton<WeatherApiDatasource>(
    () => WeatherApiDatasource(sl<http.Client>()),
  );
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(sl<WeatherApiDatasource>()),
  );
  sl.registerLazySingleton<CitySuggestionRepository>(
    () => CitySuggestionRepositoryImpl(dotenv.env['WEATHER_API_KEY']!),
  );
  sl.registerLazySingleton(
    () => GetCitySuggestions(sl<CitySuggestionRepository>()),
  );
  sl.registerLazySingleton<FavoriteCityDatasource>(
    () => FavoriteCityDatasource(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    ),
  );
  sl.registerLazySingleton<FavoriteCityRepository>(
    () => FavoriteCityRepositoryImpl(sl<FavoriteCityDatasource>()),
  );
  sl.registerLazySingleton<AddFavoriteCity>(() => AddFavoriteCity(sl()));
  sl.registerLazySingleton<RemoveFavoriteCity>(() => RemoveFavoriteCity(sl()));
}
