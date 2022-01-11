import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:weather/details_screen.dart';
import 'package:http/http.dart' as http;
import 'constants.dart' as constants;

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

class WeatherData {
  WeatherData.fromJson(Map<String,dynamic> json):

    temp = json['temp'],
    feelsLike = json['feels_like'];

  final double temp;
  final double feelsLike;
}

class _HomePageState extends State<HomePage> {
  Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;

  bool _fetchingData = false;
  WeatherData? _weatherData = null;

  @override
  void initState(){
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    _serviceEnabled = await location.serviceEnabled(); // Verifica se os serviços de localização estão ativos
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted = await location.hasPermission(); // Pede permissões em run time
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    await _getCoordinates();

    setState(() {});

    location.onLocationChanged.listen(((locationData) {
      setState(() => _locationData = locationData);
    }));
  }

  Future<void> _getCoordinates() async {
    _locationData = await location.getLocation();
  }

  Future<void> _fecthWeatherData() async{
    try{
      setState(() => _fetchingData = true);
      http.Response response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/onecall?lat='+ _locationData!.latitude.toString() + '&lon='+ _locationData!.longitude.toString() +'&exclude=minutely,hourly,alerts&units=metric&appid=' + constants.API_KEY));

      debugPrint(response.body);

      final Map<String, dynamic> decodedData = json.decode(response.body);
      setState(() => _weatherData = WeatherData.fromJson(decodedData["current"]));

    } catch(ex){
      debugPrint('Something went wrong: $ex');
    }
  }

  void _updateData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fecthWeatherData,
        tooltip: 'Update',
        child: const Icon(Icons.refresh),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            if(!_serviceEnabled)
              const Text('É necessário ativar os serviços de localização.')
            else if(_permissionGranted == PermissionStatus.denied)
              const Text('É necessário dar permissões à aplicação.')
            else if (_locationData == null)
                const CircularProgressIndicator()
              else if(_weatherData != null)
                Text('Temp: ${_weatherData!.temp.toString()}')
            else
                  const Text('Deu cocó')
          ],
        ),
      ),
    );
  }
}
