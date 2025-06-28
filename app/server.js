const express = require('express');
const path = require('path');
const fs = require('fs');
const MongoClient = require('mongodb').MongoClient;
const bodyParser = require('body-parser');

const app = express();

// Middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Serve HTML page
app.get('/', function (req, res) {
  res.sendFile(path.join(__dirname, "index.html"));
});

// Serve profile picture
app.get('/profile-picture', function (req, res) {
  const img = fs.readFileSync(path.join(__dirname, "images/profile-1.jpg"));
  res.writeHead(200, { 'Content-Type': 'image/jpg' });
  res.end(img, 'binary');
});

// MongoDB URL (use env var if set)
const mongoUrl = process.env.MONGO_URL || "mongodb://admin:password@localhost:27017";
const mongoClientOptions = { useNewUrlParser: true, useUnifiedTopology: true };
const databaseName = "user-account";

// Update user profile
app.post('/update-profile', function (req, res) {
  const userObj = req.body;

  MongoClient.connect(mongoUrl, mongoClientOptions, function (err, client) {
    if (err) {
      console.error("MongoDB connection failed:", err);
      return res.status(500).send("DB connection error");
    }

    const db = client.db(databaseName);
    userObj['userid'] = 1;

    db.collection("users").updateOne(
      { userid: 1 },
      { $set: userObj },
      { upsert: true },
      function (err) {
        client.close();
        if (err) {
          console.error("Update error:", err);
          return res.status(500).send("DB update error");
        }
        res.send(userObj);
      }
    );
  });
});

// Get user profile
app.get('/get-profile', function (req, res) {
  MongoClient.connect(mongoUrl, mongoClientOptions, function (err, client) {
    if (err) {
      console.error("MongoDB connection failed:", err);
      return res.status(500).send("DB connection error");
    }

    const db = client.db(databaseName);

    db.collection("users").findOne({ userid: 1 }, function (err, result) {
      client.close();
      if (err) {
        console.error("Fetch error:", err);
        return res.status(500).send("DB fetch error");
      }
      res.send(result || {});
    });
  });
});

// Start server on all interfaces
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', function () {
  console.log(`App listening on port ${PORT}`);
});
