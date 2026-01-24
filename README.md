# Essivi Mobile

Application mobile Flutter pour la livraison d'eau potable Essivivi.

## Description

Cette application permet aux clients de commander de l'eau potable et aux agents de gérer les livraisons. Elle inclut des fonctionnalités de tracking GPS temps réel, gestion des paniers, profils utilisateurs, et plus.

## Fonctionnalités

- Authentification multi-rôles (Client, Agent, Admin, Gestionnaire)
- Commandes et paniers
- Tracking des livraisons en temps réel
- Gestion des bouteilles et retours
- Notifications push
- Thème sombre/clair
- Internationalisation (Français/Anglais)

## Architecture

- **State Management**: Provider
- **Networking**: Dio
- **Storage**: SharedPreferences, FlutterSecureStorage
- **Maps**: FlutterMap
- **WebSocket**: Pour le tracking temps réel

## Installation

1. Cloner le repo
2. `flutter pub get`
3. Configurer l'API dans `lib/utils/api_config.dart`
4. `flutter run`

## Tests

`flutter test`

## Structure du Projet

```
lib/
├── data/          # Modèles et repositories
├── presentation/  # Écrans et widgets
├── providers/     # Gestion d'état
├── services/      # Logique métier
├── routes/        # Navigation
├── theme/         # Thèmes et couleurs
└── utils/         # Utilitaires
```

## API

L'application communique avec une API REST. Configurer l'URL dans `api_config.dart`.

## Déploiement

- Android: `flutter build apk`
- iOS: `flutter build ios`

## Contribution

1. Créer une branche feature
2. Commits descriptifs
3. Pull request

## Licence

Propriétaire - Essivivi
