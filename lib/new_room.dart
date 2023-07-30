import 'package:flutter/material.dart';
import 'package:skribbl_clone/widgets/custom_text_field.dart';
import './paint_screen.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({Key? key}) : super(key: key);

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  late String? _maxRounds;
  late String? _maxPlayers;
  // we didn't need to pass parameter in the function below because the State<CreateRoom>
  // already as the context object
  void newRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty &&
        _maxPlayers != null &&
        _maxRounds != null) {
      Map<String, String> data = {
        "playername": _nameController.text,
        "roomname": _roomNameController.text,
        // ! ->told flutter that we have initallised it late and hence can be null but we
        //are now telling flutter that they can never be null!
        "cap": _maxPlayers!,
        "rounds": _maxRounds!
      };
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PaintScreen(data: data, screenType: 'new')));
    }
  }
  //the questio mark i put above shows that the string can be null as well

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Create Room",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          //container below is to text field input to enter our name and the room name
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              nameController: _nameController,
              hintText: "Enter Your Name",
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              nameController: _roomNameController,
              hintText: "Enter Room Name",
            ),
          ),
          const SizedBox(height: 20),
          //what I have done below:
          //given items of the dropdown link as 2,4,6,8
          // then it will map through all of the above values and return a new value
          //(the one we selected) and then it will show it in the text format each and every value
          //since im mapping it
          DropdownButton<String>(
              focusColor: const Color(0xffF5F6FA),
              items: <String>["2", "4", "6", "8"]
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                  .toList(),
              hint: const Text(
                "Total Rounds",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onChanged: (String? value) {
                setState(() {
                  _maxRounds = value;
                });
              }),
          const SizedBox(height: 20),
          //here i need to add it as a widget to make it less redundant
          DropdownButton<String>(
              focusColor: const Color(0xffF5F6FA),
              items: <String>["2", "3", "4", "5", "6"]
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                  .toList(),
              hint: const Text(
                "Total Players",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onChanged: (String? value) {
                setState(() {
                  _maxPlayers = value;
                });
              }),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: newRoom,
            child: const Text(
              "Create",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.pink),
                textStyle:
                    MaterialStateProperty.all(TextStyle(color: Colors.white)),
                minimumSize: MaterialStateProperty.all(
                    Size(MediaQuery.of(context).size.width / 2.5, 50))),
          ),
        ],
      ),
    );
  }
}
