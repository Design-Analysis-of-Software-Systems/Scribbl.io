const mongoose = require('mongoose');
const { playerSchema } = require('./Player');

const roomSchema = new mongoose.Schema({
  roomname: { type: String, trim: true, unique: true, required: true },
  cap: { type: Number, default: 4, required: true },
  rounds: { type: Number, default: 4, required: true },
  currentround: { type: Number, default: 1 },
  joinstatus: { type: Boolean, default: false },
  word: { type: String, required: true },
  players: [playerSchema],
  currentplayer: playerSchema,
  turnindex: { type: Number, default: 0 },
});

const roommodel = mongoose.model('Room', roomSchema);
module.exports = roommodel;

