# Guide de Développement ScanVibe

Ce guide explique comment développer l'application ScanVibe avec Flutter (frontend) et Node.js (backend) en parallèle.

## 🏗️ Architecture

```
scanvibe/
├── lib/                    # Code Flutter (Android Studio)
│   ├── services/
│   │   └── api_service.dart
│   └── Views/
├── backend/                # Code Node.js (VS Code)
│   ├── routes/
│   ├── models/
│   └── server.js
└── README.md
```

## 🚀 Démarrage Rapide

### 1. Backend Node.js (VS Code)

```bash
# Ouvrir VS Code dans le dossier backend
cd backend
code .

# Installer les dépendances
npm install

# Créer le fichier .env
echo "PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/scanvibe
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production" > .env

# Démarrer le serveur
npm run dev
```

### 2. Frontend Flutter (Android Studio)

```bash
# Dans Android Studio, ouvrir le projet scanvibe
# Installer les nouvelles dépendances
flutter pub get

# Démarrer l'application
flutter run
```

## 🔧 Configuration

### Variables d'environnement Backend (.env)
```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/scanvibe
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:8000
```

### Configuration Flutter (lib/services/api_service.dart)
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

## 📱 Workflow de Développement

### 1. Développement Backend (VS Code)
- **Port**: 3000
- **Base de données**: MongoDB
- **API**: REST avec Express
- **Authentification**: JWT

### 2. Développement Frontend (Android Studio)
- **Framework**: Flutter
- **Communication**: HTTP avec le backend
- **Stockage local**: SharedPreferences pour les tokens

### 3. Communication Flutter ↔ Node.js

```dart
// Exemple d'utilisation dans Flutter
try {
  final result = await ApiService.login(
    email: 'user@example.com',
    password: 'password123',
  );
  print('Login successful: ${result['user']['name']}');
} catch (e) {
  print('Login failed: $e');
}
```

## 🛠️ Outils Recommandés

### VS Code Extensions (Backend)
- **ES7+ React/Redux/React-Native snippets**
- **Prettier - Code formatter**
- **ESLint**
- **MongoDB for VS Code**
- **Thunder Client** (pour tester l'API)

### Android Studio Extensions (Frontend)
- **Flutter**
- **Dart**
- **Material Theme UI**
- **Rainbow Brackets**

## 🔍 Débogage

### Backend (VS Code)
```bash
# Vérifier l'état de l'API
curl http://localhost:3000/api/health

# Tester l'authentification
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### Frontend (Android Studio)
```dart
// Ajouter des logs pour déboguer
print('API Response: $response');
```

## 📊 Base de Données

### MongoDB Collections
- **users**: Informations utilisateurs
- **scans**: Résultats de scans OCR

### Connexion
```bash
# Démarrer MongoDB localement
mongod

# Ou utiliser MongoDB Atlas (cloud)
```

## 🔒 Sécurité

### Backend
- CORS configuré pour Flutter
- Rate limiting
- Validation des fichiers
- Hashage des mots de passe
- JWT pour l'authentification

### Frontend
- Stockage sécurisé des tokens
- Validation côté client
- Gestion des erreurs réseau

## 🚀 Déploiement

### Backend
1. Configurer les variables d'environnement
2. `npm install --production`
3. `npm start`
4. Configurer un reverse proxy (nginx)

### Frontend
1. `flutter build apk`
2. `flutter build ios`
3. Publier sur App Store/Google Play

## 📝 Bonnes Pratiques

### Backend
- Utiliser des middlewares pour la validation
- Gérer les erreurs de manière centralisée
- Logs structurés
- Tests unitaires

### Frontend
- Gestion d'état avec Provider/Bloc
- Séparation des responsabilités
- Gestion des erreurs utilisateur
- Tests widget

## 🔄 Workflow Git

```bash
# Backend
cd backend
git add .
git commit -m "feat: add user authentication"
git push

# Frontend
cd ..
git add .
git commit -m "feat: integrate with backend API"
git push
```

## 📞 Support

- **Backend Issues**: Créer une issue avec le tag `backend`
- **Frontend Issues**: Créer une issue avec le tag `frontend`
- **API Documentation**: Voir `backend/README.md` 