import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:weather/details_screen.dart';
import 'package:http/http.dart' as http;
import 'constants.dart' as constants;
import 'models/weather.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiPaWeather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (_) => const HomePage(title: 'Home'),
        DetailsScreen.routeName: (_) => const DetailsScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  static const String routeName = 'HomePage';

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;

  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    _serviceEnabled = await location
        .serviceEnabled(); // Verifica se os serviços de localização estão ativos
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted =
    await location.hasPermission(); // Pede permissões em run time
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    await _getCoordinates();

    _fecthWeatherData();
    setState(() {});

    location.onLocationChanged.listen(((locationData) {
      setState(() => _locationData = locationData);
    }));
  }

  Future<void> _getCoordinates() async {
    _locationData = await location.getLocation();
  }

  bool _fetchingData = false;

  Future<void> _fecthWeatherData() async {
    try {
      setState(() => _fetchingData = true);
      http.Response response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/onecall?lat=' +
              _locationData!.latitude.toString() + '&lon=' +
              _locationData!.longitude.toString() +
              '&exclude=minutely,alerts&units=metric&appid=' +
              constants.API_KEY));

      debugPrint(response.body);

      final Map<String, dynamic> decodedData = json.decode(response.body);

      setState(() => _weather = Weather.fromJson(decodedData));
    } catch (ex) {
      debugPrint('Something went wrong: $ex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _fecthWeatherData,
        tooltip: 'Update',
        child: const Icon(Icons.refresh),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/clear.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(!_serviceEnabled)
              const Text('É necessário ativar os serviços de localização.')
            else
              if(_permissionGranted == PermissionStatus.denied)
                const Text('É necessário dar permissões à aplicação.')
              else
                if (_locationData == null || _weather == null)
                  const CircularProgressIndicator()
            else
              weatherBox(),
              hourlyBox(),
              dailyBox(),
          ],
        ),
      ),
    );
  }

  Widget weatherBox() {
    return FutureBuilder(
        builder: (context, snapshot){
        return Column(
          children: <Widget> [
            getWeatherIcon(_weather!.info.icon),
            Text(
                '${_weather!.temp} ºC',
                style: TextStyle(color: Colors.white, fontSize: 30)
            ),
            Text('Feels like: ${_weather!.feelsLike} ºC',
                style: TextStyle(color: Colors.white, fontSize: 12)
            ),
          ]
        );
        });
  }

  Widget hourlyBox() {
    return FutureBuilder(
        builder: (context, snapshot) {
          return Container(
          height: 100.0,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 8, top: 0, bottom: 0, right: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _weather!.hourly.length,
            itemBuilder: (BuildContext context, int index) {
          return Container(
            child: hourlyElement(index)
          );
          }
          )
          );
        }
      );
  }

  
  Widget hourlyElement(hoursFromNow) {
    var now = DateTime.now();
    var hours = now.add(new Duration(hours: hoursFromNow));
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(211, 211, 211, 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Text(DateFormat.H().format(hours) + 'h',
              style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              getSmallWeatherIcon(_weather!.hourly[hoursFromNow].info.icon),
              Text('${_weather!.hourly[hoursFromNow].temp.round()} ºC',
                  style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget dailyBox() {
    var now = DateTime.now();
    return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: 8, top: 50, bottom: 0, right: 8),
            itemCount: _weather!.daily.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(211, 211, 211, 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.only(
                      left: 10, top: 5, bottom: 5, right: 10),
                  margin: const EdgeInsets.all(5),
                  child: Row(children: [
                    Expanded(
                        child: Text(DateFormat.E().format(now.add(new Duration(days: index))),
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        )),
                    Expanded(
                        child: getSmallWeatherIcon(_weather!.daily[index].info.icon)),
                    Expanded(
                        child: Text(
                          "${_weather!.daily[index].min}/${_weather!.daily[index].max}",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        )),
                  ]));
            }));
  }

  Image getWeatherIcon(String _icon) {
    String path = 'assets/icons/';
    String imageExtension = ".png";
    return Image.asset(
      path + _icon + imageExtension,
      width: 70,
      height: 70,
    );
  }

  Image getSmallWeatherIcon(String _icon) {
    String path = 'assets/icons/';
    String imageExtension = ".png";
    return Image.asset(
      path + _icon + imageExtension,
      width: 40,
      height: 40,
    );
  }
}

/*
*  Expanded(
                    child: ListView.separated(
                        itemBuilder: (context,index) => ListTile(
                          title: Text('Dia #${index+1}'),
                          subtitle: Text(_weather!.daily[index].min.toString()),
                        ),
                        separatorBuilder: (_,__) => const Divider(thickness: 2,),
                        itemCount: _weather!.daily.length),
                  )
*  */