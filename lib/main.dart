import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Previsao {
  final String data;
  final double temperatura;
  final double umidade;
  final double luminosidade;
  final double vento;
  final double chuva;
  final String unidade;

  Previsao({
    required this.data,
    required this.temperatura,
    required this.umidade,
    required this.luminosidade,
    required this.vento,
    required this.chuva,
    required this.unidade,
  });

  factory Previsao.fromJson(Map<String, dynamic> json) {
    return Previsao(
      data: json['data'],
      temperatura: json['temperatura'],
      umidade: json['umidade'],
      luminosidade: json['luminosidade'],
      vento: json['vento'],
      chuva: json['chuva'],
      unidade: json['unidade'],
    );
  }
}

void main() {
  runApp(PrevisaoApp());
}

class PrevisaoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Tempo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      home: PrevisaoPage(),
    );
  }
}

class PrevisaoPage extends StatefulWidget {
  @override
  _PrevisaoPageState createState() => _PrevisaoPageState();
}

class _PrevisaoPageState extends State<PrevisaoPage> {
  late Future<List<Previsao>> previsoes;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    previsoes = fetchPrevisao();
  }

  Future<List<Previsao>> fetchPrevisao() async {
    final response =
        await http.get(Uri.parse('https://demo3520525.mockable.io/previsao'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Previsao.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar a previsão do tempo');
    }
  }

  Color getTemperatureColor(double temp) {
    if (temp < 15) return Colors.blue;
    if (temp < 25) return Colors.green;
    return Colors.orange;
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previsão do Tempo'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Previsao>>(
        future: previsoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}'),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final previsao = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(
                      'Previsão para ${previsao.data}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: [
                            _buildInfoCard(
                              'Temperatura',
                              '${previsao.temperatura}°${previsao.unidade}',
                              Icons.thermostat,
                              getTemperatureColor(previsao.temperatura),
                            ),
                            _buildInfoCard(
                              'Umidade',
                              '${previsao.umidade}%',
                              Icons.water_drop,
                              Colors.blue,
                            ),
                            _buildInfoCard(
                              'Luminosidade',
                              '${previsao.luminosidade} lux',
                              Icons.wb_sunny,
                              Colors.amber,
                            ),
                            _buildInfoCard(
                              'Vento',
                              '${previsao.vento} m/s',
                              Icons.air,
                              Colors.grey,
                            ),
                            _buildInfoCard(
                              'Chuva',
                              '${previsao.chuva} mm',
                              Icons.umbrella,
                              Colors.indigo,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma previsão disponível.'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
