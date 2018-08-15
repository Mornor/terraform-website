'use strict';

const express = require('express');
const path = require('path');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();

// Define routes and actions
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname +'/public/index.html'));
});


app.listen(PORT, HOST);
