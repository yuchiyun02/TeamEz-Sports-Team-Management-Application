import "dart:convert";
import "package:geocoding/geocoding.dart";
import "package:geolocator/geolocator.dart";

import "../models/weather_model.dart";
import "package:http/http.dart" as http;

class WeatherService {
  static const BASE_URL = "http://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);


  // Get Weather
  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));

    } else {
      throw Exception("Failed to load weather data");
    }
  }

  // Get City Name
  Future<String> getCurrentCity() async {
    // Permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied.");
        }
    }

    if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied.");
      }

    //Fetch location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placemarks[0].locality;

    return city ?? ""; //If null, return empty string
  }
}