const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');  // Importa il router di autenticazione

const app = express();

// Middleware
app.use(cors());
app.use(express.json());  // Per parsare il corpo delle richieste come JSON

// Connetti a MongoDB
mongoose.connect('mongodb+srv://stoppa2:ciao123@cluster1.7kh4b.mongodb.net/cat_connect?retryWrites=true&w=majority&appName=Cluster1', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connesso al database MongoDB'))
  .catch((err) => console.log('Errore nella connessione a MongoDB:', err));

// Usa le rotte di autenticazione
app.use('/api/auth', authRoutes);

// Porta del server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server in ascolto sulla porta ${PORT}`);
});