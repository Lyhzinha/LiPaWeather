import 'info.dart';

class Daily {

  Daily.fromJson(Map<String,dynamic> json):
        dt = json['dt'],
        min = json['temp']['min'].toDouble(),
        max = json['temp']['max'].toDouble(),
        info = Info.fromJson(json['weather'][0]);

  final int dt;
  final double min;
  final double max;
  final Info info;
}