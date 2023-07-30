const express = require("express");
const http = require("http");
const app = express();
const port = 3100; // Change the port to an available one, e.g., 3000
const server = http.createServer(app);
const mongoose = require("mongoose");
const io = require("socket.io")(server);
const Room = require('./models/Room');
const Player = require('./models/Player');
const extractWord = require('./api/extractWord');
const getWord = require("./api/extractWord");
app.use(express.json());

const DB = 'mongodb+srv://shivhareyash007:g4Hn7bhGPhWHMPDu@cluster0.sdbogvl.mongodb.net/mydatabase';

mongoose.connect(DB).then(() => {
  console.log('MongoDB Connected');
}).catch((e) => {
  console.log('MongoDB Connection Error:', e);
})

io.on('connection', (socket) => {
  console.log('Status: socket.io: OKAY(check debug console as well)');

  // Event listener for connection errors
  socket.on('error', (error) => {
    console.log('Socket Error:', error);
  });

  // Event listener for 'newmatch'
  socket.on('newmatch', async ({ playername, roomname, cap, rounds }) => {
    try {
      const existingRoom = await Room.findOne({ roomname });
      if (existingRoom) {
        socket.emit('notCorrectGame', 'Room Name already exists!. Try something else');
        return;
      }

      const word = extractWord();
      let player = { socketID: socket.id, playername, admin: true };
      let room = new Room();
      room.word = word;
      room.roomname = roomname;
      room.cap = cap;
      room.rounds = rounds;
      room.players.push(player);
      room.currentplayer = player;
      room = await room.save();
      socket.join(room.roomname);
      io.to(room.roomname).emit('updateRoom', room);
    } catch (e) {
      console.log('Error in newmatch event:', e);
    }
  });

  // event listener for existing match and joining the game
  socket.on('existing', async ({ playername, roomname }) => {
    try {
      let room = await Room.findOne({ roomname });
      if (!room) {
        socket.emit('notCorrectGame', 'Room doesn\'t exist!. Try something else');
        return;
      }
      if (room.joinstatus == true) {
        socket.emit('notCorrectGame', 'Room is full and the game has already begun. Try something else');
        return;
      }

      // Check if a player with the same name already exists in the room
      const existingPlayer = room.players.find((player) => player.playername === playername);
      if (existingPlayer) {
        socket.emit('notCorrectGame', 'Player with the same name already exists in the room. Try a different name.');
        return;
      }

      let player = { socketID: socket.id, playername, admin: false };
      room.players.push(player);
      socket.join(room.roomname);
      room.currentplayer = room.players[room.turnindex];
      if (room.cap == room.players.length) {
        room.joinstatus = true;
      }
      room = await room.save();
      io.to(room.roomname).emit('updateRoom', room);
    } catch (e) {
      console.log('Error in existingmatch event:', e);
    }
  });

  // sockets for whiteboard
  socket.on('paint', ({ details, roomname }) => {
    io.to(roomname).emit('points', { details: details });
  });
  //  sockets for colors
  socket.on('colorchange', ({ color, roomname }) => {
    io.to(roomname).emit('colorchange', color);
  });
  // sockets for width of the brush
  socket.on('width', ({ value, roomname }) => {
    io.to(roomname).emit('width', value);
  });
  socket.on('erase', (roomname) => {
    io.to(roomname).emit('erase');
  });
  socket.on('msg', async (data) => {
    console.log(data);
    try {
      if (data.msg === data.word) 
      {
        let room = await Room.find({ roomname: data.roomname });
        let userplayer = room[0].players.filter(
          (player) => player.playername === data.playername
        );
        if (data.timetaken > 0) {
          userplayer[0].points += Math.round((200 / data.timetaken) * 10);
        }
        room = await room[0].save();
        io.to(data.roomname).emit('msg', {
          playername: data.playername,
          msg: 'Player has Guessed the word!',
          turncounter: data.turncounter+1,
        });
        socket.emit('nomoreguesses',"");
      }
      else //incase they're not equal
      {
        io.to(data.roomname).emit('msg', {
          playername: data.playername,
          msg: data.msg,
          turncounter: data.turncounter,
        });
      }
    } catch (e) {
      console.log("error in guessing part!");
    }
  });
  socket.on('turnchange', async (roomname) => {
    try {
      let room = await Room.findOne({ roomname });
      let turnindex = room.turnindex;
      // i.e. everyone's chance has come
      if (turnindex + 1 === room.players.length) {
        room.currentround += 1;
      }
      if (room.currentround <= room.rounds) {
        // i.e. if there are still rounds left
        const word = getWord();
        room.word = word;
        room.turnindex = (turnindex + 1) % room.players.length;
        room.currentplayer = room.players[room.turnindex];
        room = await room.save();
        // Emit the updated room data to the specific room using io.to(roomname).emit('updateRoom', room);
        io.to(roomname).emit('turnchange', room);
      } else {
        // otherwise show the leaderboard
        io.to(roomname).emit('showleaderboard',room.players);
      }
    } catch (error) {
      console.log("Error in turnchange event:", error);
    }
  });
  socket.on('getscore',async(roomname)=>{
    try{
      const room = await Room.findOne({roomname});
      io.to(roomname).emit('getscore',room);
    }
    catch(e)
    {
      console.log('error in getting the updated score',e);
    }
  });
  socket.on('disconnect',async()=>{
    try{
      let room  = Room.findOne({"players.socketID": socket.id});
      let i=0;
      while(i<room.players.length)
      {
        if(room.players[i].socketID==socket.id)
        {
          room.players.splice(i,1);
          break;
        }
        i++;
      }
      room = await room.save();
      if(room.players.length==1)
      {
        socket.broadcast.to(room.roomname).emit('leaderboard',room.players);
      }
      else
      {
        socket.broadcast.to(room.roomname).emit('playerdisconnected',room);        
      }
    }
    catch(e)
    {
      console.log('error in disconnecting',e);
    }
  });
});

server.listen(port, "0.0.0.0", () => {
  console.log('Server Running');
});
