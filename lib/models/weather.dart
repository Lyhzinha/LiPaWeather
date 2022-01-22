import 'package:weather/models/daily.dart';
import 'package:weather/models/hourly.dart';

import 'info.dart';

class Weather {
  Weather.fromJson(Map<String,dynamic> json):

        temp = json['current']['temp'],
        feelsLike = json['current']['feels_like'],
        info = Info.fromJson(json['current']['weather'][0]),
        hourly = (json['hourly'] as List).map((hour) => Hourly.fromJson(hour)).toList(),
        daily = (json['daily'] as List).map((day) => Daily.fromJson(day)).toList();

  Map<String, dynamic> toJson() => {
    'current': {
      'temp': temp,
      'feels_like': feelsLike,
      'weather': [info.toJson()],
    },
    'hourly': hourly,
    'daily': daily
  };

  final double temp;
  final double feelsLike;
  final Info info;
  final List<Hourly> hourly;
  final List<Daily> daily;
}


