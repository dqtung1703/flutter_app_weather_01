import 'package:flutter/material.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherNowWidget extends StatefulWidget {
  final String city;
  const WeatherNowWidget({Key? key, required this.city}) : super(key: key);

  @override
  State<WeatherNowWidget> createState() => _WeatherNowWidgetState();
}

class _WeatherNowWidgetState extends State<WeatherNowWidget> {
  late WeatherRepositoryImpl repo;
  WeatherModel? weather;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    repo = WeatherRepositoryImpl(
      WeatherRemoteDataSourceImpl(http.Client(), 'b0ee8bb4ad5a2fc82fcf925a0ac3d3fb'),
    );
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() { isLoading = true; });
    weather = await repo.getWeatherByCity(widget.city);
    setState(() { isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
      ? const Center(child: CircularProgressIndicator())
      : weather == null
        ? const Center(child: Text('No data'))
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${weather!.cityName}, ${weather!.country}', style: const TextStyle(fontSize: 22)),
              Image.network('https://openweathermap.org/img/wn/${weather!.iconCode}@2x.png', width: 50),
              Text('${weather!.temperature}°C', style: const TextStyle(fontSize: 36)),
              Text(weather!.description, style: const TextStyle(fontSize: 18)),
            ],
          );
  }
}
