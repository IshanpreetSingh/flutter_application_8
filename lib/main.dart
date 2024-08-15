import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Card Battle',
      theme: ThemeData(
        primarySw
        atch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PokemonBattlePage(),
    );
  }
}

class PokemonBattlePage extends StatefulWidget {
  @override
  _PokemonBattlePageState createState() => _PokemonBattlePageState();
}

class _PokemonBattlePageState extends State<PokemonBattlePage> {
  dynamic _pokemonCard1;
  dynamic _pokemonCard2;
  String _winner = "";
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _fetchAndComparePokemonCards();
  }

  Future<void> _fetchAndComparePokemonCards() async {
    setState(() {
      _pokemonCard1 = null;
      _pokemonCard2 = null;
      _winner = "";
    });

    final cards = await _fetchPokemonCards();

    if (cards.length >= 2) {
      setState(() {
        _pokemonCard1 = cards[_random.nextInt(cards.length)];
        _pokemonCard2 = cards[_random.nextInt(cards.length)];
        while (_pokemonCard2 == _pokemonCard1) {
          _pokemonCard2 = cards[_random.nextInt(cards.length)];
        }
        _winner = _determineWinner(_pokemonCard1, _pokemonCard2);
      });
    }
  }

  Future<List<dynamic>> _fetchPokemonCards() async {
    final url = Uri.parse('https://api.pokemontcg.io/v2/cards?pageSize=50');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load Pokémon cards');
    }
  }

  String _determineWinner(dynamic card1, dynamic card2) {
    final hp1 = int.tryParse(card1['hp'] ?? '0') ?? 0;
    final hp2 = int.tryParse(card2['hp'] ?? '0') ?? 0;

    if (hp1 > hp2) {
      return "${card1['name']} wins with ${hp1} HP!";
    } else if (hp2 > hp1) {
      return "${card2['name']} wins with ${hp2} HP!";
    } else {
      return "It's a tie!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon Card Battle'),
        backgroundColor: Colors.redAccent,
      ),
      body: _pokemonCard1 == null || _pokemonCard2 == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPokemonCard(_pokemonCard1),
                      _buildPokemonCard(_pokemonCard2),
                    ],
                  ),
                ),
                Text(
                  _winner,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchAndComparePokemonCards,
                  child: Text('Battle Again'),
                ),
              ],
            ),
    );
  }

  Widget _buildPokemonCard(dynamic card) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              card['images']['large'],
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              card['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'HP: ${card['hp']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
