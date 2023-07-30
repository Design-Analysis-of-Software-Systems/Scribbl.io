const mongoose = require('mongoose');
const playerSchema = new mongoose.Schema({
  playername: {
    type: String,
    trim: true,
    required: true,
    unique: true,
  },
  socketID: { type: String },
  admin: { type: Boolean, default: false },
  points: { type: Number, default: 0 },
});

const playermodel = mongoose.model('Player', playerSchema);
module.exports = { playermodel, playerSchema };
