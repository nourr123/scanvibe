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

## 📱 API Endpoints

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
```
backend/
├── config/
│   └── database.js
├── middleware/
│   └── auth.js
├── models/
│   ├── User.js
│   └── Scan.js
├── routes/
│   ├── auth.js
│   ├── scan.js
│   └── user.js
├── uploads/
├── package.json
├── server.js
└── README.md
```

### Variables d'environnement
- `PORT` : Port du serveur (défaut: 3000)
- `MONGODB_URI` : URI de connexion MongoDB
- `JWT_SECRET` : Clé secrète pour JWT
- `NODE_ENV` : Environnement (development/production)

## 🔒 Sécurité

- CORS configuré pour Flutter
- Rate limiting
- Validation des fichiers upload
- Hashage des mots de passe
- Authentification JWT

## 📝 Notes

- Les images sont stockées dans le dossier `uploads/`
- L'OCR est simulé (remplacez par votre service OCR)
- MongoDB est utilisé comme base de données
- JWT pour l'authentification

## 🚀 Déploiement

1. Configurer les variables d'environnement
2. Installer les dépendances : `npm install`
3. Démarrer : `npm start`
4. Configurer un reverse proxy si nécessaire 