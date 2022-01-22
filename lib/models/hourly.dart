import 'info.dart';

class Hourly {
  Hourly.fromJson(Map<String,dynamic> json):

        dt = json['dt'],
        temp = json['temp'].toDouble(),
        info = Info.fromJson(json['weather'][0]);

  Map<String, dynamic> toJson() => {
    'dt': dt,
    'temp': temp,
    'weather': [ info.toJson() ]
  };

  final int dt;
  final double temp;
  final Info info;
}