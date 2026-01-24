# Connexion Mobile-Backend Essivi

## Vue d'ensemble

L'application mobile Essivi est maintenant connectée au backend Django via l'API REST configurée avec Traefik.

## Configuration API

### URLs de connexion

**Développement :**
- **API Base** : `http://localhost/api` (via Traefik)
- **WebSocket** : `ws://localhost/ws/notifications/`
- **Dashboard Traefik** : `http://traefik.localhost/`

**Android Emulator :**
- **API Base** : `http://10.0.2.2/api`
- **WebSocket** : `ws://10.0.2.2/ws/notifications/`

**Production :**
- **API Base** : `https://api.essivivi.com/api`
- **WebSocket** : `wss://api.essivivi.com/ws/notifications/`

### Architecture de connexion

```
Mobile App (Flutter)
    ↓ HTTP/WebSocket
Traefik (Port 80)
    ↓
Backend Django (Port 8000)
    ↓
PostgreSQL + Redis + MongoDB
```

## Services configurés

### AuthService
- **Login** : `POST /users/token/`
- **Signup** : `POST /users/users/`
- **Profile** : `GET /users/me/`
- **Token Refresh** : `POST /users/token/refresh/`

### WebSocketService
- **Notifications** : `ws://localhost/ws/notifications/`
- **Authentification** : Token JWT dans query parameter

### Autres services
- **LocationService** : Géolocalisation
- **CartService** : Gestion du panier
- **RoutingService** : Calcul d'itinéraires

## Sécurité

### Authentification
- **JWT Tokens** : Access + Refresh tokens
- **Stockage sécurisé** : FlutterSecureStorage
- **Auto-refresh** : Intercepteur Dio pour renouvellement automatique

### CORS
- Headers configurés dans Traefik
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, OPTIONS, PUT, POST, DELETE, PATCH`
- `Access-Control-Allow-Headers: *`

## Démarrage

### 1. Backend
```bash
cd C:\ProjetIAI\essivi-backend\infrastructure\docker
docker-compose up -d
```

### 2. Mobile
```bash
cd C:\ProjetIAI\Mobile_essivivi
flutter run
```

### 3. Vérification
- **API** : `http://localhost/api/schema/` (HTTP 200)
- **Traefik** : `http://traefik.localhost/`
- **Mobile** : Écran de connexion fonctionnel

## Endpoints principaux

### Utilisateurs
- `GET /users/me/` - Profil utilisateur
- `GET /users/agents/` - Liste des agents
- `GET /users/clients/` - Liste des clients

### Commandes
- `GET /sales/commandes/` - Liste des commandes
- `POST /sales/commandes/` - Créer une commande

### Livraisons
- `GET /logistics/livraisons/` - Liste des livraisons
- `PUT /logistics/livraisons/{id}/` - Mettre à jour une livraison

## Dépannage

### Problème : Connexion impossible
**Solution** : Vérifier que le backend Docker fonctionne
```bash
docker-compose ps
curl http://localhost/api/schema/
```

### Problème : WebSocket ne se connecte pas
**Solution** : Vérifier l'URL WebSocket dans `ApiConfig.wsUrl`

### Problème : Erreur CORS
**Solution** : Vérifier la configuration Traefik dans `infrastructure/traefik/traefik.yml`

## Tests

### Tests unitaires
```bash
flutter test
```

### Tests d'intégration
- Se connecter avec un compte test
- Créer une commande
- Vérifier les notifications WebSocket

---

**Status** : ✅ Connecté et fonctionnel
**Date** : 24 Janvier 2026