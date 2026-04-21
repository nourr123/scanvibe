# ScanVibe Backend API

Backend Node.js pour l'application Flutter ScanVibe.

## 🚀 Installation

### Prérequis
- Node.js (v14 ou supérieur)
- MongoDB (local ou cloud)
- npm ou yarn

### Installation des dépendances
```bash
cd backend
npm install
```

### Configuration
1. Créer un fichier `.env` dans le dossier `backend/` :
```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/scanvibe
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:8000
```

### Démarrage
```bash
# Mode développement (avec nodemon)
npm run dev

# Mode production
npm start
```

## �� API Endpoints

### Authentification
- `POST /api/auth/signup` - Inscription
- `POST /api/auth/login` - Connexion
- `GET /api/auth/me` - Profil utilisateur
- `POST /api/auth/logout` - Déconnexion

### Scans
- `POST /api/scan/upload` - Upload d'image
- `POST /api/scan/process/:scanId` - Traitement OCR
- `GET /api/scan/list` - Liste des scans
- `GET /api/scan/:scanId` - Détails d'un scan
- `DELETE /api/scan/:scanId` - Supprimer un scan

### Utilisateur
- `GET /api/user/profile` - Profil utilisateur
- `PUT /api/user/profile` - Modifier le profil
- `POST /api/user/profile-picture` - Photo de profil
- `PUT /api/user/password` - Changer le mot de passe
- `DELETE /api/user/account` - Désactiver le compte

### Santé
- `GET /api/health` - Vérification de l'état de l'API

## 🔧 Configuration Flutter

Dans votre application Flutter, configurez l'URL de base :

```dart
const String baseUrl = 'http://localhost:3000/api';
```

## 🛠️ Développement

### Structure du projet