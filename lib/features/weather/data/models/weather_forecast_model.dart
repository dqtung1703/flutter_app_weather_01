class WeatherForecastModel {
  final DateTime dateTime; // Giờ local city
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final String description;
  final String iconCode;

  WeatherForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.description,
    required this.iconCode,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json, int timezoneOffset) {
    // Chuẩn bị time đúng dạng cho cả /forecast và /onecall
    DateTime localTime;
    if (json.containsKey('dt_txt')) {
      // /forecast 3h/lần (dt_txt là chuỗi yyyy-MM-dd HH:mm:ss UTC)
      final utcTime = DateTime.parse(json['dt_txt']);
      localTime = utcTime.add(Duration(seconds: timezoneOffset));
    } else if (json.containsKey('dt')) {
      // /onecall - daily/hourly
      final utcTime = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true);
      localTime = utcTime.add(Duration(seconds: timezoneOffset));
    } else {
      localTime = DateTime.now();
    }

    // Xử lý từng kiểu temp (onecall: day/min/max trong temp map, forecast: main)
    double temp, tempMin, tempMax;
    if (json.containsKey('main')) {
      temp = (json['main']['temp'] as num).toDouble();
      tempMin = (json['main']['temp_min'] as num).toDouble();
      tempMax = (json['main']['temp_max'] as num).toDouble();
    } else {
      // Onecall
      temp = (json['temp'] is Map)
          ? (json['temp']['day'] as num).toDouble() // daily
          : (json['temp'] as num).toDouble();      // hourly
      tempMin = (json['temp'] is Map)
          ? (json['temp']['min'] as num).toDouble()
          : temp;
      tempMax = (json['temp'] is Map)
          ? (json['temp']['max'] as num).toDouble()
          : temp;
    }

    return WeatherForecastModel(
      dateTime: localTime,
      temperature: temp,
      minTemperature: tempMin,
      maxTemperature: tempMax,
      description: json['weather'][0]['description'] as String,
      iconCode: json['weather'][0]['icon'] as String,
    );
  }
}
