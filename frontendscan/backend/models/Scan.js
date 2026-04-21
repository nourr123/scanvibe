const mongoose = require('mongoose');

const scanSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  imageUrl: {
    type: String,
    required: true
  },
  scanType: {
    type: String,
    enum: ['text', 'qr', 'barcode', 'document'],
    default: 'text'
  },
  extractedText: {
    type: String,
    default: ''
  },
  confidence: {
    type: Number,
    min: 0,
    max: 1,
    default: 0
  },
  language: {
    type: String,
    default: 'en'
  },
  tags: [{
    type: String
  }],
  isProcessed: {
    type: Boolean,
    default: false
  },
  processingTime: {
    type: Number, // en millisecondes
    default: 0
  },
  metadata: {
    originalFileName: String,
    fileSize: Number,
    mimeType: String,
    dimensions: {
      width: Number,
      height: Number
    }
  }
}, {
  timestamps: true
});

// Index pour améliorer les performances
scanSchema.index({ user: 1, createdAt: -1 });
scanSchema.index({ scanType: 1 });
scanSchema.index({ isProcessed: 1 });

module.exports = mongoose.model('Scan', scanSchema); 