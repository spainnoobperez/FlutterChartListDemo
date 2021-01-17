import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

void main() => runApp(new PrimeraApp());

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <String>[];
  final _biggerFont = const TextStyle(fontSize: 19.0);
  final _saved = new Set<String>();
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  random(min, max){
    var rn = new Random();
    return min + rn.nextInt(max - min);
  }

  generateWordPairs(int n) {
    List<String> lst = [];
    for(int i=0;i<n;i++) {
      lst.add(getRandomString(n));
    }
    return lst;
  }

  Widget _buildRow(String pair) {
    final alreadySaved = _saved.contains(pair);
    return new ListTile(
      title: new Text(
        pair.toLowerCase(),
        style: _biggerFont,
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
        padding: const EdgeInsets.all(15.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return new Divider();
          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs(random(100,200)));
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }

  void Abrir() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => SegundaApp()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Startup Name Generator'),
        actions: <Widget>[
        new IconButton(icon: new Icon(Icons.list), onPressed: Abrir),
      ],
      ),
      body: _buildSuggestions(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  createState() => new RandomWordsState();
}

class PrimeraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      home: new RandomWords(),
    );
  }
}

//// Second App

class SegundaApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Chart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Chart Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.white.withOpacity(0.4),
        alignment: Alignment.center,
        child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height / 2),
          painter: CharLinePainter(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back),
        onPressed: (){
          print('FloatingActionButton');
          Navigator.pop(context);
        },
      ),
    );
  }
}

class CharLinePainter extends CustomPainter {
  static const double basePadding = 16;

  double startX, endX;
  double startY, endY;
  double _fixedWidth;
  double _fixedHeight;
  Path _path = new Path();

  @override
  void paint(Canvas canvas, Size size) {
    _initBorder(size);
    _drawXy(canvas);
    _drawXYRulerText(canvas);
    _drawLine(canvas);
  }

  void _initCurvePath(int i, double xRulerW, double yRulerH) {
    if (i == 0) {
      var key = startX;
      var value = startY;
      _path.moveTo(key, value);
    } else {
      double preX = startX + xRulerW * i;
      double preY = (startY - (i % 2 != 0 ? yRulerH : yRulerH * 20));
      double currentX = startX + xRulerW * (i+1);
      double currentY = (startY - (i % 2 == 0 ? yRulerH : yRulerH * 20));

      _path.cubicTo((preX + currentX) / 2, preY, (preX + currentX) / 2, currentY, currentX, currentY);
    }
  }

  void _drawShader(canvas, shadowPath) {
    var shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.repeated,
        colors: [
          Colors.deepPurple.withOpacity(0.5),
          Colors.red.withOpacity(0.5),
          Colors.cyan.withOpacity(0.5),
          Colors.deepPurpleAccent.withOpacity(0.5),
        ]).createShader(Rect.fromLTRB(startX, endY, startX, startY));

    shadowPath
      ..lineTo(startX + _fixedWidth, startY)
      ..lineTo(startX, startY)
      ..close();

    canvas
      ..drawPath(
          shadowPath,
          new Paint()
            ..shader = shader
            ..isAntiAlias = true
            ..style = PaintingStyle.fill);
  }


  void _drawXYRulerText(Canvas canvas) {
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.square
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    int rulerCount = 25;

    double xRulerW = _fixedWidth / rulerCount;
    double yRulerH = _fixedHeight / rulerCount;

    double reduceRuler = 10.0;
    for (int i = 1; i <= rulerCount; i++) {
      _drawXRuler(canvas, xRulerW, yRulerH, reduceRuler, i, paint);
      _drawYRuler(canvas, xRulerW, yRulerH, reduceRuler, i, paint);
      _drawXText(canvas, xRulerW, i);
      _drawYText(canvas, yRulerH, i);
      _initCurvePath(i-1, xRulerW, yRulerH);
    }
  }

  void _drawXy(Canvas canvas){
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.square
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(startX, startY), Offset(endX , startY), paint);
    canvas.drawLine(Offset(startX, startY), Offset(startX, endY), paint);
  }

  void _drawXRuler(Canvas canvas, double xRulerW, double yRulerH,
      double reduceRuler, int i, var paint) {
    double drawRulerSx = startX + xRulerW * i;
    double drawRulerSy = startY;
    double drawRulerEx = startX + xRulerW * i;
    double drawRulerEy = startY - yRulerH + reduceRuler;
    canvas.drawLine(Offset(drawRulerSx, drawRulerSy),
        Offset(drawRulerEx, drawRulerEy), paint);
  }

  void _drawYRuler(Canvas canvas, double xRulerW, double yRulerH,
      double reduceRuler, int i, var paint) {
    double drawRulerSx = startX;
    double drawRulerSy = startY - i * yRulerH;
    double drawRulerEx = startX + xRulerW - reduceRuler;
    double drawRulerEy = startY - i * yRulerH;
    canvas.drawLine(Offset(drawRulerSx, drawRulerSy),
        Offset(drawRulerEx, drawRulerEy), paint);
  }

  void _drawXText(Canvas canvas,double xRulerW,int i) {
    TextPainter(
        textAlign: TextAlign.center,
        ellipsis: '.',
        text: TextSpan(
            text: (i-1).toString(),
            style: TextStyle(color: Colors.white, fontSize: 10.0)),
        textDirection: TextDirection.ltr)
      ..layout(minWidth: xRulerW, maxWidth: xRulerW)
      ..paint(canvas, Offset(startX + xRulerW * (i - 1) - xRulerW / 2, startY+basePadding/2));
  }

  void _drawLine(canvas) {
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    var pathMetrics = _path.computeMetrics(forceClosed: false);
    var list = pathMetrics.toList();
    var length = list.length.toInt();
    Path linePath = new Path();
    Path shadowPath = new Path();
    for (int i = 0; i < length; i++) {
      var extractPath = list[i].extractPath(0, list[i].length, startWithMoveTo: true);
      shadowPath = extractPath;
      linePath.addPath(extractPath, Offset(0, 0));
    }
    canvas.drawPath(linePath, paint);
    _drawShader(canvas, shadowPath);
  }

  void _drawYText(Canvas canvas,double yRulerH,int i) {
    TextPainter(
        textAlign: TextAlign.center,
        ellipsis: '.',
        text: TextSpan(
            text: (i-1).toString(),
            style: TextStyle(color: Colors.white, fontSize: 10.0)),
        textDirection: TextDirection.ltr)
      ..layout(minWidth: yRulerH, maxWidth: yRulerH)
      ..paint(canvas, Offset(startX-basePadding/2*3,startY - yRulerH * (i - 1) - yRulerH / 2));
  }

  void _initBorder(Size size) {
    startX = basePadding * 2;
    endX = size.width - basePadding * 2;
    startY = size.height - basePadding * 2;
    endY = basePadding * 2;
    _fixedWidth = endX - startX;
    _fixedHeight = startY - endY;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}