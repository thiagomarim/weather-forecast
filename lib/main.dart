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
      title: 'Previsão',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: Colors.black,
          surface: Colors.white,
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
      throw Exception('Falha ao carregar dados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previsão', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Previsao>>(
        future: previsoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final previsao = snapshot.data![index];
                return Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        previsao.data,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${previsao.temperatura}°${previsao.unidade}',
                            style: TextStyle(fontSize: 32),
                          ),
                          Row(
                            children: [
                              Icon(Icons.water_drop, size: 16),
                              Text(' ${previsao.umidade}%'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.air, size: 16),
                          Text(' ${previsao.vento} m/s'),
                          SizedBox(width: 16),
                          Icon(Icons.umbrella, size: 16),
                          Text(' ${previsao.chuva} mm'),
                        ],
                      ),
                      Divider(height: 32),
                    ],
                  ),
                );
              },
            );
          }
          return Center(child: Text('Sem dados disponíveis'));
        },
      ),
    );
  }
}
