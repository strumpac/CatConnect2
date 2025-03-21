const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
  const token = req.header("Authorization");

  if (!token) return res.status(401).json({ message: "Accesso negato. Nessun token fornito." });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Salviamo l'utente nel request
    next();
  } catch (error) {
    res.status(401).json({ message: "Token non valido." });
  }
};

module.exports = authMiddleware;
