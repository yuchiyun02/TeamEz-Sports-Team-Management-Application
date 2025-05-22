import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/models/weather_model.dart';
import 'package:teamez/pages/notes/home_notes_view.dart';
import 'package:teamez/services/weather_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamez/widgets/events/events_tab.dart';
import 'package:teamez/models/events_model.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _weatherService = WeatherService(Keys.weatherService);
  Weather? _weather;
  String? _teamName;

  String userId = FirebaseAuth.instance.currentUser!.uid;

  _fetchTeamName() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _teamName = userDoc['teamName'] ?? 'Team Name';
        });
      }
    } catch (e) {
      print('Error fetching team name: $e');
    }
  }

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    }

    catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';

      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';

      case 'thunderstorm':
        return 'assets/thunder.json';

      case 'clear':
        return 'assets/sunny.json';

      default:   
        return 'assets/sunny.json'; 
    }
  }

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
    _fetchWeather();
    _fetchTeamName();
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomCol.bgGreen,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
              height: 100,
              width: 325,
              color: CustomCol.bgGreen,
              child: Text("Welcome Back, \n${_teamName ?? "Loading..."}!",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold)
                )
              ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              //Notes widget
              HomeNotesView(userId: userId),

              //Weather widget
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20, width: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("${_weather?.temperature.round() ?? "--"}", 
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: CustomCol.black),
                            ),

                        //Align to top
                        Baseline(
                          baseline: 5,
                          baselineType: TextBaseline.alphabetic,
                          child: Text("°C",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CustomCol.black)
                        )),
                        
                        Lottie.asset(getWeatherAnimation((_weather?.mainCondition)),width: 50, height: 50),
                    ],
                    ),
                    
                    Text(_weather?.cityName ?? "city",
                      style: TextStyle(
                        fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: CustomCol.black
                      ),),

                    Text("Condition: ${_weather?.mainCondition ?? 'weather'}",
                      style: TextStyle(
                        fontSize: 15,
                            color: CustomCol.black
                      ),),

                    Text("Wind Speed: ${_weather?.windSpeed.toStringAsFixed(1) ?? ''} m/s",
                      style: TextStyle(
                        fontSize: 15,
                            color: CustomCol.black
                      ),),
                    
                    Text("Humidity: ${_weather?.humidity.toString() ?? ''}%",
                      style: TextStyle(
                        fontSize: 15,
                            color: CustomCol.black
                      ),),
                  ]
              )
            ],
          ),

          //Events viewer
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('events').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No events found.'));
                    }
              
                    final events = snapshot.data!.docs
                        .map((doc) => Event.fromFirestore(doc))
                        .toList();
              
                    return EventsTab(events: events);
                  },
                ),
            ),
          ),

        ],

      )
    );
  }
}