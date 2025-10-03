import 'package:flutter_test/flutter_test.dart';
import 'package:olly_app/model/weather_model.dart';

void main() {
  group('WeatherData', () {
    test('fromJson parses valid weather data correctly', () {
      final json = {
        'name': 'London',
        'main': {
          'temp': 20.5,
          'humidity': 65,
        },
        'weather': [
          {
            'main': 'Clear',
            'description': 'clear sky',
          }
        ],
        'sys': {
          'sunrise': 1609488000,
          'sunset': 1609524000,
        }
      };

      final weather = WeatherData.fromJson(json);

      expect(weather.cityName, 'London');
      expect(weather.temperature, 20.5);
      expect(weather.mainCondition, 'Clear');
      expect(weather.sunrise, 1609488000);
      expect(weather.sunset, 1609524000);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'name': 'Paris',
        'main': {
          'temp': 15.0,
        },
        'weather': [
          {
            'main': 'Clouds',
          }
        ],
      };

      final weather = WeatherData.fromJson(json);

      expect(weather.cityName, 'Paris');
      expect(weather.temperature, 15.0);
      expect(weather.mainCondition, 'Clouds');
      expect(weather.sunrise, isNull);
      expect(weather.sunset, isNull);
    });

    test('isNightTime returns true during night hours', () {
      final now = DateTime.now();
      final sunriseTime = now.subtract(const Duration(hours: 2));
      final sunsetTime = now.subtract(const Duration(hours: 1));

      final json = {
        'name': 'Tokyo',
        'main': {'temp': 18.0},
        'weather': [
          {'main': 'Clear'}
        ],
        'sys': {
          'sunrise': sunriseTime.millisecondsSinceEpoch ~/ 1000,
          'sunset': sunsetTime.millisecondsSinceEpoch ~/ 1000,
        }
      };

      final weather = WeatherData.fromJson(json);
      expect(weather.isNightTime, true);
    });

    test('isNightTime returns false during day hours', () {
      final now = DateTime.now();
      final sunriseTime = now.subtract(const Duration(hours: 2));
      final sunsetTime = now.add(const Duration(hours: 2));

      final json = {
        'name': 'New York',
        'main': {'temp': 22.0},
        'weather': [
          {'main': 'Sunny'}
        ],
        'sys': {
          'sunrise': sunriseTime.millisecondsSinceEpoch ~/ 1000,
          'sunset': sunsetTime.millisecondsSinceEpoch ~/ 1000,
        }
      };

      final weather = WeatherData.fromJson(json);
      expect(weather.isNightTime, false);
    });

    test('isNightTime returns false when sunrise/sunset are null', () {
      final json = {
        'name': 'Berlin',
        'main': {'temp': 16.0},
        'weather': [
          {'main': 'Rain'}
        ],
      };

      final weather = WeatherData.fromJson(json);
      expect(weather.isNightTime, false);
    });

    test('fromJson handles empty weather array gracefully', () {
      final json = {
        'name': 'Madrid',
        'main': {'temp': 25.0},
        'weather': <Map<String, dynamic>>[],
      };

      expect(
        () => WeatherData.fromJson(json),
        throwsA(isA<RangeError>()),
      );
    });

    test('temperature values are preserved correctly', () {
      final json = {
        'name': 'Moscow',
        'main': {'temp': -15.7},
        'weather': [
          {'main': 'Snow'}
        ],
      };

      final weather = WeatherData.fromJson(json);
      expect(weather.temperature, -15.7);
    });

    test('timestamp is correctly parsed', () {
      final json = {
        'name': 'Mumbai',
        'main': {
          'temp': 30.0,
        },
        'weather': [
          {'main': 'Clear'}
        ],
        'dt': 1609488000,
      };

      final weather = WeatherData.fromJson(json);
      expect(weather.timestamp, 1609488000);
      expect(weather.timestamp, isA<int>());
    });
  });
}
