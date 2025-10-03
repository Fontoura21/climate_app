class WeatherData {
  final double temperature;
  final String cityName;
  final String mainCondition;
  final int? sunrise;
  final int? sunset;
  final int timestamp;

  WeatherData({
    required this.temperature,
    required this.cityName,
    required this.mainCondition,
    this.sunrise,
    this.sunset,
    required this.timestamp,
  });

  // check if it's currently nighttime
  bool get isNightTime {
    if (sunrise == null || sunset == null) {
      // fallback: assume night between 6 PM and 6 AM
      final hour = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).hour;
      return hour >= 18 || hour < 6;
    }
    return timestamp < sunrise! || timestamp > sunset!;
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: WeatherInfo.fromJson(json['weather'][0]).main,
      sunrise: json['sys']?['sunrise'],
      sunset: json['sys']?['sunset'],
      timestamp: json['dt'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }
}

class WeatherInfo {
  final String main;

  WeatherInfo({
    required this.main,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      main: json['main'],
    );
  }
}

class Temperature {
  final double current;

  Temperature({required this.current});

  factory Temperature.fromJson(dynamic json) {
    return Temperature(
      current: (json - 273.15), // kelvin to celsius
    );
  }
}

class Wind {
  final double speed;

  Wind({required this.speed});

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(speed: json['speed']);
  }
}
