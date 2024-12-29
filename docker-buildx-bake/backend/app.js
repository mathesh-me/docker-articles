const express = require('express');
const app = express();

const PORT = 3000;

// Middleware to parse JSON
app.use(express.json());

// API Endpoint
app.get('/', (req, res) => {
  res.send('Hello from the Backend!');
});

// Start the server
app.listen(PORT, () => {
  console.log(`Backend server is running on port ${PORT}`);
});
