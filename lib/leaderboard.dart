import 'package:flutter/material.dart';

class FinalLeaderboard extends StatelessWidget {
  final scoreboard;
  final String winner;
  const FinalLeaderboard(this.scoreboard, this.winner);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        height: double.maxFinite,
        child: Column(
          children: [
            Text(
              "FINAL LEADERBOARD",
              style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 33),
            ),
            ListView.builder(
                primary: true,
                shrinkWrap: true,
                itemCount: scoreboard.length, //imp!!
                itemBuilder: (context, index) {
                  var data = scoreboard[index].values;
                  return ListTile(
                    title: Text(data.elementAt(0),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 23)),
                    trailing: Text(data.elementAt(1),
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  );
                }),
            Text(
              "Congratulations! $winner",
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ],
        ),
      ),
    );
  }
}
