const mongoose = require('mongoose');

// Schema per il post
const postSchema = new mongoose.Schema({
    imageUrl: { type: String, required: true },
    description: { type: String, required: true },
    author: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    comments: [{type: mongoose.Schema.Types.ObjectId, ref: 'Comment'}],
    breed : {type: String}
});


const Post = mongoose.model('Post', postSchema);

module.exports = Post;
