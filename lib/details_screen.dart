import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/models/daily.dart';

class DetailsScreen extends StatefulWidget{
  const DetailsScreen({Key? key}) : super(key: key);
  static const String routeName = 'DetailsScreen';

  @override
  State<StatefulWidget> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>{
  late final Daily _weather = ModalRoute.of(context)!.settings.arguments as Daily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/${_weather.info.main.toLowerCase()}.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            weatherBox(),
            detailsBox()
          ],
        ),
      ),
    );
  }

  Widget weatherBox() {
    return FutureBuilder(
        builder: (context, snapshot){
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
                children: <Widget> [
                  Text(DateFormat.EEEE().format(new DateTime.fromMillisecondsSinceEpoch(_weather.dt * 1000)),
                      style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)
                  ),
                  getWeatherIcon(_weather.info.icon),
                  Text(
                      'Min: ${_weather.min.round()} ºC Max: ${_weather.max.round()} ºC',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ]
            ),
          );
        });
  }

  Widget detailsBox() {
    return FutureBuilder(
        builder: (context, snapshot){
          return Container(
              width: 320.0,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [
                      Row(children: [
                            getSmallWeatherIcon('sunrise'),
                           Expanded(child:
                                Text('Sunrise',
                                    textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.white, fontSize: 20)),
                              ),
                            Expanded(child :
                            Text(
                                '${DateFormat.Hm().format(new DateTime.fromMillisecondsSinceEpoch(_weather.sunrise * 1000))}',
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.white, fontSize: 20)
                            ),
                            ),
                          ]),
                      Row(
                            children: [
                              getSmallWeatherIcon('sunset'),
                              Expanded(child:
                                    Text('Sunset',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Colors.white, fontSize: 20)),
                              ),

                              Expanded(child :
                              Text(
                                  '${DateFormat.Hm().format(new DateTime.fromMillisecondsSinceEpoch(_weather.sunset * 1000))}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(color: Colors.white, fontSize: 20)
                              ),
                              ),
                            ]),

                      Row(
                            children: [
                              getSmallWeatherIcon('humidity'),
                              Expanded(child:
                                Text('Humidity',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Colors.white, fontSize: 20)),
                                ),

                              Expanded(child :
                              Text(
                                  '${_weather.humidity}%',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(color: Colors.white, fontSize: 20)
                              ),
                              ),
                            ]),

                       Row(
                            children: [
                              getSmallWeatherIcon('wind'),
                               Expanded(child:
                                Text('Wind',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Colors.white, fontSize: 20)),
                                ),
                              Expanded(child :
                              Text(
                                  '${_weather.wind}Km/h',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(color: Colors.white, fontSize: 20)
                              ),
                              ),
                            ]),

                    ]
                ),

          );
        });
  }

  Image getWeatherIcon(String _icon) {
    String path = 'assets/icons/';
    String imageExtension = ".png";
    return Image.asset(
      path + _icon + imageExtension,
      width: 200,
      height: 200,
    );
  }

  Image getSmallWeatherIcon(String _icon) {
    String path = 'assets/icons/';
    String imageExtension = ".png";
    return Image.asset(
      path + _icon + imageExtension,
      width: 30,
      height: 30,
    );
  }
}