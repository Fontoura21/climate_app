import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:olly_app/model/weather_model.dart';

class WeatherServices {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherServices(this.apiKey);

  Future<WeatherData> getWeatherByCity(String cityName) async {
    final response = await http
        .get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<WeatherData> getWeatherByCoordinates(double lat, double lon) async {
    final response = await http.get(
        Uri.parse('$BASE_URL?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<WeatherData> getCurrentWeather() async {
    // check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && !kIsWeb) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    // get permission from user
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied. Please enable them in Settings.');
    }

    // fetch current location with timeout
    // web uses lower accuracy as high accuracy may not work in all browsers
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: kIsWeb ? LocationAccuracy.medium : LocationAccuracy.high,
      timeLimit: Duration(seconds: kIsWeb ? 15 : 10),
    ).timeout(
      Duration(seconds: kIsWeb ? 20 : 15),
      onTimeout: () {
        throw Exception(
            'Location request timed out. Please check your browser settings.');
      },
    ).catchError((e) {
      throw Exception('Unable to get current location: $e');
    });

    // use coordinates directly to get weather (more reliable)
    return await getWeatherByCoordinates(position.latitude, position.longitude);
  }

  Future<String> getCityNameFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        String? city = placemarks.first.locality;
        return city ?? 'Unknown Location';
      }
    } catch (e) {
      // silently handle geocoding errors
    }
    return 'Unknown Location';
  }
}
