import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainLobby extends StatefulWidget {
  final String lobbyname;
  final players;
  final int max;
  final int curr;
  const MainLobby(
      {Key? key,
      required this.max,
      required this.curr,
      required this.lobbyname,
      required this.players})
      : super(key: key);

  @override
  State<MainLobby> createState() => _MainLobbyState();
}

class _MainLobbyState extends State<MainLobby> {
  @override
  Widget build(BuildContext context) {
    // the safe area basically ignores the notch area where theres battery life ,network,etc
    // and starts rendering from below
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                  'Kindly wait while the others join.(${widget.max - widget.curr} players remaining)',
                  style: TextStyle(fontSize: 25))),
          SizedBox(height: MediaQuery.of(context).size.height * 0.06),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              readOnly: true,
              onTap: () {
                // copy roomname
                Clipboard.setData(ClipboardData(text: widget.lobbyname));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied Successfully!')));
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                //  whenever the user clicks,we want the text enabled and want to give the same border
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: const Color(0xffF5F5FA),
                // hintText: "Enter Your Name",
                //  creating a template instead of directly writing enter your name since you will need to keep on changing that
                hintText: 'tap to copy roomname!',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Text('Players: ', style: TextStyle(fontSize: 18)),
          ListView.builder(
              // we use list view builder when we usually dont know how many values will be there
              // we have used primary to make it scroll enabled and keeping it at the center
              primary: true,
              shrinkWrap: true,
              itemCount: widget.curr,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    "${index + 1}.",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  title: Text(
                    widget.players[index]['playername'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              })
        ],
      ),
    );
  }
}
