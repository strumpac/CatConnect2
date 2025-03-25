const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Post = require('../models/Post');
const authMiddleware = require('../middleware/authMiddleware');
const router = express.Router();

// Registrazione
router.post('/register', async (req, res) => {
  const { username, email, password, profilePictureUrl } = req.body; // Ottieni l'URL dell'immagine

  // Verifica se l'URL dell'immagine è presente
  if (!profilePictureUrl) {
    return res.status(400).json({ message: 'L\'URL dell\'immagine del profilo è obbligatorio' });
  }

  try {
    // Controlla se l'email esiste già
    const existingMail = await User.findOne({ email });
    if (existingMail) {
      return res.status(400).json({ message: 'Email già in uso' });
    }

    const existingUsername = await User.findOne({ username });
    if (existingUsername) {
      return res.status(400).json({ message: 'Username già in uso' });
    }

    const user = new User({
      username,
      email,
      password,
      profilePictureUrl // Salva l'URL dell'immagine
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

// Aggiungo il posto al database
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
});

// Recupero tutti i post dell'utente
router.get('/getUserPosts/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const posts = await Post.find({ author: userId }).populate('author', 'username');
    res.status(200).json(posts);
  } catch (error) {
    res.status(500).json({ error: 'Errore nel recupero dei post' });
  }
});

router.get('/me', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    console.log(userId)
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'Utente non trovato' });
    }

    res.json({
      username: user.username,
      email: user.email,
      profilePictureUrl: user.profilePictureUrl,
      followers: user.followers,
      following: user.following,
      posts: user.posts,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/searchUsers', async (req, res) => {
  try {
    const { query } = req.query;
    if (!query) {
      return res.status(400).json({ message: 'Nessun termine di ricerca fornito' });
    }

    const users = await User.find({ 
      username: { $regex: query, $options: 'i' } 
    }).select('username profilePictureUrl');

    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Errore nel recupero degli utenti' });
  }
});


module.exports = router;