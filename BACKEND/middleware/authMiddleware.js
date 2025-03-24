const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
  const token = req.header("Authorization");

  if (!token) {
    return res.status(401).json({ message: "Accesso negato. Nessun token fornito." });
  }

  try {
    console.log(token);
    const decoded = jwt.verify(token, 'secretKey'); // Usa la stessa chiave segreta del login
    console.log('Token decodificato: ', decoded);
    req.user = {
      id: decoded.userId // Estrai l'ID dell'utente dalla chiave 'userId' del token
    };
    next();
  } catch (error) {
    console.log("token non valido")
    return res.status(401).json({ message: "Token non valido." });
  }
};

module.exports = authMiddleware;