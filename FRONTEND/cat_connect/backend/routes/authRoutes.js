const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');  // Il modello User definito sopra
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

    // Crea un nuovo utente
    const user = new User({
      username,
      email,
      password
    });

    // Salva l'utente nel database
    await user.save();

    // Invia una risposta di successo
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

module.exports = router;
