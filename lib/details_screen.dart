import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget{
  const DetailsScreen({Key? key}) : super(key: key);
  static const String routeName = 'DetailsScreen';

  @override
  State<StatefulWidget> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista de detalhes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Isto vai ser a vista de detalhes')
          ],
        ),
      ),
    );
  }


}