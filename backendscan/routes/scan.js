
const express = require('express');
const router = express.Router();

// Route de test pour scan
router.get('/test', (req, res) => {
  res.json({ message: 'Scan routes working!' });
});

module.exports = router; 
