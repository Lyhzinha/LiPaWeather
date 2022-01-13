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
        backgroundColor: Color.fromRGBO(173, 216, 230, 1),
        onPressed: _fecthWeatherData,
        tooltip: 'Update',
        child: const Icon(Icons.refresh),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/${_weather!.info.main.toLowerCase()}.png'),
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
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: <Widget> [
              getWeatherIcon(_weather!.info.icon),
              Text(
                  '${_weather!.temp.round()} ºC',
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)
              ),
              Text('Feels like: ${_weather!.feelsLike} ºC',
                  style: TextStyle(color: Colors.white, fontSize: 12)
              ),
              Text(' ${_weather!.info.main}', //TODO: APAGAR - só serve para debug da imagem de fundo
                  style: TextStyle(color: Colors.white, fontSize: 12)
              ),
            ]
          ),
        );
        });
  }

  Widget hourlyBox() {
    return FutureBuilder(
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Container(
                width: 375.0,
                height: 65.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(211, 211, 211, 0.3),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Container(
                  width: 300.0,
                  child: ListView.builder(
                padding: const EdgeInsets.all(3),
                scrollDirection: Axis.horizontal,
                itemCount: _weather!.hourly.length,
                itemBuilder: (BuildContext context, int index) {
              return Container(
                child: hourlyElement(index)
              );
              }
              ),
            )
            ),
          );
        }
      );
  }

  
  Widget hourlyElement(hoursFromNow) {
    var now = DateTime.now();
    var hours = now.add(new Duration(hours: hoursFromNow));
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
          child: Column(
            children: <Widget>[
             /* Text('${_weather!.hourly[hoursFromNow].temp.round()} ºC',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),*/
              getSmallWeatherIcon(_weather!.hourly[hoursFromNow].info.icon),
              Text(DateFormat.H().format(hours) + 'h',
                style: TextStyle(color: Colors.white, fontSize: 10),
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
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Container(
            width: 300.0,
            child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: const EdgeInsets.only(left: 8, top: 10, bottom: 20, right: 8),
                itemCount: _weather!.daily.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                        DetailsScreen.routeName,
                        arguments: _weather!.daily[index]
                    ),
                    child: Container(
                        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
                        margin: const EdgeInsets.all(5),
                        child: Row(children: [
                          Expanded(
                              child: Text(DateFormat.EEEE().format(now.add(new Duration(days: index))),
                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                              )),
                          Expanded(
                              child: getSmallWeatherIcon(_weather!.daily[index].info.icon)),
                          Expanded(
                              child: Text(
                                "${_weather!.daily[index].max.round()}ºC /${_weather!.daily[index].min.round()}ºC",
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                              )),
                        ])),
                  );
                }),
          ),
        ));
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