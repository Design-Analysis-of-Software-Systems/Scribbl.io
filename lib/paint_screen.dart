// import 'dart:html';
// import 'dart:js';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_clone/home_screen.dart';
import 'package:skribbl_clone/leaderboard.dart';
import 'package:skribbl_clone/lobby_screen.dart';
import 'package:skribbl_clone/models/touch_point.dart';
import 'package:skribbl_clone/widgets/scoreboard_drawer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:skribbl_clone/models/my_custom_painter.dart';

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenType;
  PaintScreen({required this.data, required this.screenType});

  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  bool isTextInputReadOnly = false;
  bool finalLeaderboardOut = false;
  var scaffoldkey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  int _start = 60;
  late Timer _timer;
  int turncounter = 0;
  Map roomInfo = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  double flag = 1;
  List<Widget> blankText = [];
  List<Map> messages = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  int maxPoints = 0;
  String winner = "";

  @override
  void initState() {
    super.initState();
    // for the socket io client connections
    connect();
    print(widget.data);
    print(widget.screenType);
  }

  void renderBlankText(String word) {
    blankText.clear();
    int j = 0;
    while (j < word.length) {
      blankText.add(Text('|_|',
          style: TextStyle(fontSize: 50, color: Colors.purpleAccent)));
      j++;
    }
  }

  void startTimer() {
    const sec = const Duration(seconds: 1);
    _timer = Timer.periodic(sec, (Timer time) {
      if (_start == 0) {
        _socket.emit('turnchange', roomInfo['roomname']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void connect() {
    _socket = IO.io('http://192.168.134.51:3100', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });

    _socket.onConnect((data) {
      print('connected!');
      _socket.on(
          'notCorrectGame',
          (data) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false));
      _socket.on('playerdisconnected', (v) {
        scoreboard.clear();
        int i = 0;
        while (i < v.length) {
          setState(() {
            scoreboard.add({
              'playername': v[i]['playername'],
              'points': v[i]['points'].toString()
            });
          });
          // /*
          //   {
          //     points: x
          //     playername:y
          //   }
          // */
          // if (maxPoints < int.parse(scoreboard[i]['points'])) {
          //   maxPoints = int.parse(scoreboard[i]['points']);
          //   winner = scoreboard[i]['playername'];
          // }
          i++;
        }
        setState(() {
          _timer.cancel();
          finalLeaderboardOut = true;
        });
      });
      _socket.on('updateRoom', (roomData) {
        print(roomData['word']);
        // applying setState so that UI also changes automatically!
        setState(() {
          renderBlankText(roomData['word']);
          roomInfo = roomData;
        });
        if (roomData['joinstatus'] == true) {
          // if all have joined, we will start the timer
          startTimer();
        }
        scoreboard.clear();
        int i = 0;
        while (i < roomData['players'].length) {
          scoreboard.add({
            'playername': roomData['players'][i]['playername'],
            'points': roomData['players'][i]['points']
                .toString(), //.tostring used since points is int in mongo
          });
          i++;
        }
      });
      _socket.on('points', (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
                points: Offset((point['details']['dx']).toDouble(),
                    point['details']['dy'].toDouble()),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
            // all the variables mentioned above have been declared on the top
          });
        }
      });
      _socket.on('colorchange', (colorString) {
        int value = int.parse(colorString, radix: 16);
        Color newColor = new Color(value);
        setState(() {
          selectedColor = newColor;
        });
      });
      _socket.on('width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });
      _socket.on('erase', (v) {
        setState(() {
          points.clear();
        });
      });
      _socket.on('msg', (v) {
        setState(() {
          messages.add(v);
          turncounter = v['turncounter'];
          print(turncounter);
        });
        // i.e. if everyone's turn is done we head to the next round
        if (turncounter ==
            roomInfo['players'].length -
                1) //-1 since the one drawing wont guess
        {
          _socket.emit('turnchange', roomInfo['roomname']);
        }
        // in case the the chats are too long it would automatically scroll to the newest ones
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });
      _socket.on('turnchange', (data) {
        String currwrd = roomInfo['word'];
        showDialog(
            context: context,
            builder: (context) {
              // i have applied this delayer so that for 1st three seconds it displays the word to
              // guessed and then applies the new changes
              Future.delayed(Duration(seconds: 3), () {
                setState(() {
                  roomInfo = data;
                  renderBlankText(data['word']);
                  turncounter = 0;
                  points.clear();
                  _start = 60;
                  isTextInputReadOnly = false;
                });
                // inorder to remove that dialogue box after 5 seconds
                Navigator.of(context).pop();
                _timer.cancel();
                startTimer();
              });
              return AlertDialog(
                title: Center(child: Text('Word to be guessed was: $currwrd')),
              );
            });
      });
      if (widget.screenType == 'new') {
        // Emit the 'newmatch' event only after successful connection
        _socket.emit('newmatch', widget.data);
      } else {
        _socket.emit('existing', widget.data);
        setState(() {
          isTextInputReadOnly = true;
        });
      }
    });
    _socket.on('nomoreguesses', (_) {
      _socket.emit('getscore', widget.data['roomname']);
    });
    _socket.on('getscore', (v) {
      scoreboard.clear();
      int i = 0;
      while (i < v['players'].length) {
        setState(() {
          scoreboard.add({
            'playername': v['players'][i]['playername'],
            'points': v['players'][i]['points'].toString()
          });
        });
        i++;
      }
    });
    _socket.on('showleaderboard', (allplayers) {
      scoreboard.clear();
      int i = 0;
      while (i < allplayers.length) {
        setState(() {
          scoreboard.add({
            'playername': allplayers[i]['playername'],
            'points': allplayers[i]['points'].toString()
          });
        });
        /*
          {
            points: x
            playername:y
          } 
        */
        if (maxPoints < int.parse(scoreboard[i]['points'])) {
          maxPoints = int.parse(scoreboard[i]['points']);
          winner = scoreboard[i]['playername'];
        }
        i++;
      }
      setState(() {
        _timer.cancel();
        finalLeaderboardOut = true;
      });
    });
    _socket.onConnectError((error) {
      print('Connection error: $error');
    });

    _socket.onDisconnect((data) {
      print('Disconnected!');
    });

    // Connect to the socket after setting up event listeners
    _socket.connect();
  }

  @override
  // this method is used to dispose off inorder to prevent memory leak!
  void dispose() {
    _socket.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    void selectColor() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Choose Color'),
                content: SingleChildScrollView(
                  // downloaded the module flutter_colour picker from pub.dev for this
                  // you can also use the pubspec assist extension on the vscode and
                  // enter pubspec assist on the commande pallete and then type colour_picker and run
                  child: BlockPicker(
                    pickerColor: selectedColor,
                    // we can't directly use socket.emit('color',color) since socket wont be
                    // able to accept it and there will be errors and all and we are passing as string and
                    //color code(hex value)  as shown below.
                    onColorChanged: (color) {
                      String colorString = color.toString();
                      String valueString =
                          colorString.split('(0x')[1].split(')')[0];
                      print(colorString);
                      print(valueString);
                      Map map = {
                        'color': valueString,
                        'roomname': roomInfo['roomname']
                      };
                      // now we finally emit :)
                      _socket.emit('colorchange', map);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Select'))
                ],
              ));
    }

    return Scaffold(
      key: scaffoldkey,
      drawer: PlayerScore(scoreboard),
      // main background color of the paintscreen
      backgroundColor: Colors.purple.shade50,
      body: roomInfo != null
          ? roomInfo['joinstatus'] != false
              ? !finalLeaderboardOut
                  ? Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: width,
                              height: height * 0.55,
                              child: GestureDetector(
                                // onPanUpdate detects the drag motion
                                onPanUpdate: (details) {
                                  print(details.localPosition.dx);
                                  _socket.emit('paint', {
                                    'details': {
                                      'dx': details.localPosition.dx,
                                      'dy': details.localPosition.dy,
                                      // we didnt use global position since its for the entire screen
                                    },
                                    'roomname': widget.data['roomname'],
                                  });
                                },
                                // onPanStart detects if the screen has been touched
                                // we didn't use ontap since we can do long press as well!
                                onPanStart: (details) {
                                  print(details.localPosition.dx);
                                  _socket.emit('paint', {
                                    'details': {
                                      'dx': details.localPosition.dx,
                                      'dy': details.localPosition.dy,
                                      // we didnt use global position since its for the entire screen
                                    },
                                    'roomname': widget.data['roomname'],
                                  });
                                },
                                // tells that the user interaction is finished
                                onPanEnd: (details) {
                                  _socket.emit('paint', {
                                    'details': null,
                                    'roomname': widget.data['roomname'],
                                  });
                                },
                                child: SizedBox.expand(
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: RepaintBoundary(
                                      child: CustomPaint(
                                        size: Size.infinite,
                                        painter:
                                            MyCustomPainter(pointsList: points),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(children: [
                              // change color of the brush
                              IconButton(
                                icon: Icon(Icons.color_lens_sharp,
                                    color: selectedColor),
                                onPressed: () {
                                  selectColor();
                                },
                              ),
                              // increase/decrease brush width
                              Expanded(
                                child: Slider(
                                  min: 1.0,
                                  max: 10,
                                  label: "StrokeWidth $strokeWidth",
                                  activeColor: selectedColor,
                                  value: strokeWidth,
                                  onChanged: (double value) {
                                    Map map = {
                                      'value': value,
                                      'roomname': roomInfo['roomname'],
                                    };
                                    _socket.emit('width', map);
                                  },
                                ),
                              ),
                              // clear whatever has been drwan on the whiteboard
                              IconButton(
                                icon: Icon(Icons.layers_clear_sharp,
                                    color: selectedColor),
                                onPressed: () {
                                  _socket.emit('erase', roomInfo['roomname']);
                                },
                              ),
                            ]),
                            roomInfo['currentplayer']['playername'] !=
                                    widget.data['playername']
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: blankText,
                                  )
                                : Center(
                                    child: Text(
                                      roomInfo['word'],
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.pink.shade100),
                                    ),
                                  ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: messages.length,
                                  controller: _scrollController,
                                  itemBuilder: (context, index) {
                                    var msg = messages[index].values;
                                    return ListTile(
                                      title: Text(
                                        msg.elementAt(0),
                                        style: TextStyle(
                                            color: Colors.purpleAccent,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        msg.elementAt(1),
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 15,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                        // a basic ternary operator which prevent the user drawing from guessing the
                        // the word himself/herself
                        roomInfo['currentplayer']['playernmae'] !=
                                widget.data['playername']
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  // I didnt directly use custom text field becaus ei wanted to add additonal features
                                  child: TextField(
                                    readOnly:
                                        isTextInputReadOnly, //if the user has already guessed
                                    controller: controller,
                                    autocorrect: false, //new feature
                                    onSubmitted: (guess) {
                                      if (guess.trim().isNotEmpty) {
                                        Map map = {
                                          'playername':
                                              widget.data['playername'],
                                          'msg': guess.trim(),
                                          'word': roomInfo['word'],
                                          'roomname': roomInfo['roomname'],
                                          'turncounter': turncounter,
                                          'totaltime': 60,
                                          'timetaken': 60 - _start,
                                        };
                                        _socket.emit('msg', map);
                                        controller.clear();
                                      }
                                    }, //new feature
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      //  whenever the user clicks,we want the text enabled and want to give the same border
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                      filled: true,
                                      fillColor: const Color(0xffF5F5FA),
                                      // hintText: "Enter Your Name",
                                      //  creating a template instead of directly writing enter your name since you will need to keep on changing that
                                      hintText: 'Guess Here',
                                      hintStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    textInputAction:
                                        TextInputAction.done, //new feature
                                  ),
                                ),
                              )
                            : Container(),
                        SafeArea(
                          child: IconButton(
                            icon: Icon(Icons.multiline_chart_sharp,
                                color: Colors.grey.shade400),
                            onPressed: () =>
                                scaffoldkey.currentState!.openDrawer(),
                          ),
                        ),
                        // SafeArea(child: IconButton(icon: Icon(Icons.menu,color: Colors.black),
                        // ))
                      ],
                    )
                  : FinalLeaderboard(scoreboard, winner)
              : MainLobby(
                  lobbyname: roomInfo['roomname'],
                  curr: roomInfo['players'].length,
                  max: roomInfo['cap'],
                  players: roomInfo['players'],
                )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 6,
          backgroundColor: Colors.pink,
          child: Text(
            '$_start',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 22),
          ),
        ),
      ),
    );
  }
}
