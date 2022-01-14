import 'info.dart';

class Daily {

  Daily.fromJson(Map<String,dynamic> json):
        dt = json['dt'],
        min = json['temp']['min'].toDouble(),
        max = json['temp']['max'].toDouble(),
        sunrise = json['sunrise'],
        sunset = json['sunset'],
        humidity = json['humidity'].toDouble(),
        wind = json['wind_speed'].toDouble(),
        info = Info.fromJson(json['weather'][0]);

  final int dt;
  final double min;
  final double max;
  final int sunrise;
  final int sunset;
  final double humidity;
  final double wind;
  final Info info;
}