const mongoose = require('mongoose');

// Schema per il post
const scoreSchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    score : {type: Number}
});


const Score = mongoose.model('Score', postSchema);

module.exports = Score;
