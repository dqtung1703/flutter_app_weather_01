import 'package:flutter/material.dart';
import '../../data/repositories/weather_forecast_repository_impl.dart';
import '../../data/datasources/weather_forecast_remote_datasource.dart';
import '../../data/models/weather_forecast_model.dart';
import 'package:http/http.dart' as http;

class WeatherForecastWidget extends StatefulWidget {
  final String city;
  const WeatherForecastWidget({Key? key, required this.city}) : super(key: key);

  @override
  State<WeatherForecastWidget> createState() => _WeatherForecastWidgetState();
}

class _WeatherForecastWidgetState extends State<WeatherForecastWidget> {
  late WeatherForecastRepositoryImpl repo;
  List<WeatherForecastModel> forecastList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Khởi tạo datasource với API key của bạn
    final ds = WeatherForecastRemoteDataSource(http.Client(), 'b0ee8bb4ad5a2fc82fcf925a0ac3d3fb');
    repo = WeatherForecastRepositoryImpl(ds);
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    setState(() { isLoading = true; });
    forecastList = await repo.getForecastByCity(widget.city);
    setState(() { isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
      ? const Center(child: CircularProgressIndicator())
      : SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecastList.length,
            itemBuilder: (context, i) {
              final item = forecastList[i];
              return Card(
                color: Colors.blueGrey[900],
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${item.dateTime.hour}:00', style: const TextStyle(color: Colors.white)),
                      Image.network('https://openweathermap.org/img/wn/${item.iconCode}@2x.png', width: 36),
                      Text('${item.temperature}°C', style: const TextStyle(color: Colors.white)),
                      Text(item.description, style: const TextStyle(color: Colors.white, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        );
  }
}
