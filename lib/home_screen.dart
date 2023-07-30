import 'package:flutter/material.dart';
import 'package:skribbl_clone/join_room.dart';
import 'package:skribbl_clone/new_room.dart';

//type stf to get the basic template
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //bruteforce to change color:
          // const Text(
          //   "create/join a room to play!",
          //   style: TextStyle(color: Colors.purpleAccent,fontSize: 24),
          // ),
          //this is bow you change colors of each words individually..
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Create",
                  style: TextStyle(color: Colors.pink, fontSize: 24),
                ),
                TextSpan(
                  text: "/",
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
                TextSpan(
                  text: "Join",
                  style: TextStyle(color: Colors.purpleAccent, fontSize: 24),
                ),
                TextSpan(
                  text: " a room to Play!",
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            //  space between the above text and the buttons below
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //provides space between the buttons
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateRoom(),
                  ),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.pink),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(color: Colors.white)),
                    minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width / 2.5, 50))),
                child: const Text(
                  "Create",
                  style: TextStyle(fontSize: 21),
                  // style: TextStyle(
                  //   color: Colors.black,
                  // ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const JoinRoom(),
                  ),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.purpleAccent),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(color: Colors.white)),
                    minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width / 2.5, 50))),
                child: const Text(
                  "Join",
                  style: TextStyle(fontSize: 21),
                  // style: TextStyle(
                  //   color: Colors.black,
                  // ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
