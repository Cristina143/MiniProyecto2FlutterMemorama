import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class GamePage extends StatefulWidget {
  final int numPairs;

  GamePage({required this.numPairs});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> _images = [];
  List<bool> _revealed = [];
  List<int> _selectedIndices = [];
  Timer? _timer;
  int _seconds = 0;
  bool _gameOver = false;
  int _foundPairs = 0;
  int? _bestTime;

  @override
  void initState() {
    super.initState();
    _startGame();
    _loadBestTime();
  }

  void _startGame() {
    _images = _generateImageList();
    _revealed = List.generate(widget.numPairs * 2, (_) => false); // Inicializa las tarjetas como ocultas
    _selectedIndices = [];
    _foundPairs = 0;
    _gameOver = false;
    _seconds = 0;

    // Inicia el cronómetro
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_gameOver) {
        timer.cancel();
      } else {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  Future<void> _loadBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'bestTime_${widget.numPairs}';
    setState(() {
      _bestTime = prefs.getInt(key);
    });
  }

  Future<void> _saveBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'bestTime_${widget.numPairs}';
    final currentBestTime = prefs.getInt(key);

    if (currentBestTime == null || _seconds < currentBestTime) {
      await prefs.setInt(key, _seconds);
      setState(() {
        _bestTime = _seconds;
      });
    }
  }

  List<String> _generateImageList() {
    List<String> baseImages = [
      'cerdo.png', 'gato.png', 'leon.png', 'perro.png', 'pez.png', 'tortuga.png'
    ];

    List<String> selectedImages;

    if (widget.numPairs == 8) {
      selectedImages = baseImages.sublist(0, 4); // 4 imágenes para 8 pares
    } else if (widget.numPairs == 10) {
      selectedImages = baseImages.sublist(0, 5); // 5 imágenes para 10 pares
    } else if (widget.numPairs == 12) {
      selectedImages = baseImages.sublist(0, 6); // 6 imágenes para 12 pares
    } else {
      selectedImages = [];
    }

    List<String> imagePairs = [...selectedImages, ...selectedImages]..shuffle();
    return imagePairs;
  }

  void _onCardTap(int index) {
    if (_revealed[index] || _selectedIndices.length == 2 || _gameOver) return;

    setState(() {
      _revealed[index] = true;
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      // Comparamos las dos tarjetas seleccionadas
      if (_images[_selectedIndices[0]] == _images[_selectedIndices[1]]) {
        _foundPairs++;
        _selectedIndices.clear();

        if (_foundPairs == (widget.numPairs/2)) {
          print("Juego terminado, todos los pares encontrados");
          _gameOver = true;
          _saveBestTime();
          _stopTimer(); 
          _showWinDialog();
        }
      } else {
        // Esconder las tarjetas después de un retraso
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _revealed[_selectedIndices[0]] = false;
            _revealed[_selectedIndices[1]] = false;
            _selectedIndices.clear();
          });
        });
      }
    }
  }

  // Nueva función para detener el cronómetro
  void _stopTimer() {
    if (_timer != null) {
      _timer?.cancel();  // Detenemos el cronómetro
      print("Cronómetro detenido en $_seconds segundos");
    }
  }

  // Nueva función para mostrar el diálogo de victoria
  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¡Ganaste!"),
          content: Text("Tu tiempo es de: $_seconds segundos\n"
              "Tu récord en ${widget.numPairs} pares es: $_bestTime segundos"),
          actions: <Widget>[
            TextButton(
              child: Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Regresa a la página anterior (HomePage)
              },
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[200],
        title: Text('Memorama'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: _images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: Card(
                    child: _revealed[index]
                        ? Image.asset('assets/${_images[index]}')
                        : Container(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Tiempo: $_seconds segundos',
              style: TextStyle(fontSize: 24),
            ),
          ),
          if (_bestTime != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Su mejor tiempo es: $_bestTime segundos',
                style: TextStyle(fontSize: 24),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
