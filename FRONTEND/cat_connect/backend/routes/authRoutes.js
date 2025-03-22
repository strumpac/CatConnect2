const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');  
const Post = require('../models/Post');
const router = express.Router();

// Registrazione
router.post('/register', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    // Controlla se l'email esiste già
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email già in uso' });
    }

    
    const user = new User({
      username,
      email,
      password
    });

    // Salva l'utente nel database
    await user.save();

    res.status(201).json({ message: 'Utente registrato con successo' });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Errore del server' });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Trova l'utente con l'email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Credenziali errate' });
    }

    // Confronta la password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Credenziali errate' });
    }

    // Crea un JWT
    const token = jwt.sign({ userId: user._id }, 'secretKey', { expiresIn: '1h' });

    // Invia il token come risposta
    res.status(200).json({ token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Errore del server' });
  }
});

//aggiungo il posto al database
router.post('/addPost', async (req, res) => {
  const { imageUrl, description, author } = req.body;

  try {
      const newPost = await Post.create({ imageUrl, description, author });

      // Aggiungo il post nella lista dei post dell'utente
      await User.findByIdAndUpdate(author, { $push: { posts: newPost._id } });

      res.status(201).json(newPost);
  } catch (error) {
      res.status(500).json({ error: 'Errore nella creazione del post' });
  }
})

//recupero tutti i post dell'utente
router.get('/getUserPosts/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const posts = await Post.find({ author: userId }).populate('author', 'username');
    res.status(200).json(posts);
  } catch (error) {
    res.status(500).json({ error: 'Errore nel recupero dei post' });
  }
});

module.exports = router;
