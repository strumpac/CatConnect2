const mongoose = require("mongoose");
require("dotenv").config();

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("✅ MongoDB connesso");
  } catch (error) {
    console.error("❌ Errore di connessione:", error);
    process.exit(1);
  }
};

module.exports = connectDB;
