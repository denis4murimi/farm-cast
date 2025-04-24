import 'package:farmcast/constants.dart';
import 'package:farmcast/models/weather_model.dart';
import 'package:farmcast/services/weather_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  int _currentIndex = 0;
  WeatherFactory wf = WeatherFactory(OPENWEATHER_API_KEY);

  void _onTabTapped(int index) async {
    setState(() {
      _currentIndex = index;

      if (index == 0) {
        Navigator.pushNamed(context, '/overview');
        //Navigator.push(context, OverviewPage() as Route<Object?>);
      } else if (index == 1) {
        //Navigator.push(context, AddcropPage() as Route<Object?>);
        Navigator.pushNamed(context, '/addCrop');
      }
    });
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Cast', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              logout();
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green, Colors.green.shade300, Colors.white70],
                ),
              ),
              child: FutureBuilder<List<WeatherForecast>>(
                future: WeatherService.fetch5DayForecast(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final forecasts = snapshot.data!;
                    final todayForecast = forecasts.first;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${WeatherService.city} ${todayForecast.temperature.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'High: ${todayForecast.tempMax.toStringAsFixed(1)}°C, Low: ${todayForecast.tempMin.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Image.network(
                                'http://openweathermap.org/img/wn/${todayForecast.icon}@2x.png',
                                width: 100,
                                height: 100,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                forecasts.map((forecast) {
                                  return Card(
                                    color: Colors.lightBlue[100],
                                    margin: const EdgeInsets.all(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            DateFormat(
                                              'EEE, MMM d',
                                            ).format(forecast.dateTime),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Image.network(
                                            'http://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                                          ),
                                          Text(
                                            forecast.weatherDescription,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${forecast.temperature.toStringAsFixed(1)}°C',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error!\n${snapshot.error}'));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              color: Colors.white70,
              child: FutureBuilder(
                future: FirebaseFirestore.instance.collection('crops').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No crops found'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final crop = snapshot.data!.docs[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: Image.network(
                            crop['imageUrlList'][0],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(crop['name']),
                          subtitle: Text(
                            crop['description'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                '/cropDetails',
                                arguments: {
                                  "id": crop.id,
                                  "name": crop['name'],
                                  "description": crop['description'],
                                  "imageUrlList": crop['imageUrlList'],
                                },
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CropImage extends StatelessWidget {
  const CropImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/corn.jpg', fit: BoxFit.fill);
  }
}
