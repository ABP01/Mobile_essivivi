# Projet Essivi Mobile

Ce document présente l'architecture technique et les principales fonctionnalités de l'application **Essivi Mobile**.

## Architecture du Projet

L'application est développée avec **Flutter** et suit une architecture modulaire organisée par couches et par fonctionnalités :

*   **`lib/presentation/`** : Contient l'interface utilisateur. Subdivisée en `screens` (écrans complets) et `widgets` (composants réutilisables).
    *   `screens/client/` : Écrans dédiés aux clients.
    *   `screens/agent/` : Écrans dédiés aux agents (livreurs).
    *   `screens/auth/` : Écrans d'authentification.
*   **`lib/data/`** : Gère l'accès aux données (APIs, services distants).
*   **`lib/providers/`** : Gestion de l'état (State Management) utilisant le package `provider` (ex: `ThemeProvider`, `NotificationProvider`, `LanguageProvider`).
*   **`lib/models/`** : Définition des modèles de données.
*   **`lib/services/`** : Services utilitaires (Authentification, etc.).
*   **`lib/routes/`** : Configuration du système de routage centralisé.
*   **`lib/l10n/`** : Gestion de l'internationalisation (Français et Anglais) via ARB files.
*   **`lib/theme/`** : Définition du design system (couleurs, polices, thèmes clair et sombre).

---

## Fonctionnalités Principales

### 1. Authentification
*   Accès restreint pour les clients et agents.
*   Gestion du profil utilisateur et changement de mot de passe.

### 2. Interface Client (Client)
*   **Tableau de bord** : Vue d'ensemble des commandes en cours.
*   **Gestion des commandes** : Création de nouvelles commandes d'eau et historique des livraisons.
*   **Suivi en direct (Tracking)** : Visualisation en temps réel de la position du livreur sur une carte.
*   **Retour de bouteilles** : Gestion de l'inventaire et retour des bouteilles vides.
*   **Abonnements** : Gestion des services de livraison récurrents.
*   **Qualité de l'eau** : Consultation des rapports sur la qualité de l'eau livrée.
*   **Support & Aide** : Centre d'aide et contact via WhatsApp/Email.

### 3. Interface Agent (Livreur)
*   **Gestion des livraisons** : Réception et gestion des missions de livraison attribuées.
*   **Tableau de bord Agent** : Statistiques quotidiennes (bouteilles livrées, gains, heures travaillées).
*   **Preuve de livraison** : Capture de photos ou signatures pour confirmer les livraisons.
*   **Gestion des gains** : Suivi détaillé des revenus et historique des paiements.
*   **Inventaire des bouteilles** : Suivi des stocks de bouteilles dans le véhicule.

### 4. Fonctionnalités Transverses
*   **Internationalisation** : Support complet du Français et de l'Anglais.
*   **Mode Sombre (Dark Mode)** : Interface dynamique s'adaptant aux préférences système.
*   **Notifications** : Système d'alertes en temps réel pour le statut des commandes.
*   **Design Premium** : Utilisation des Google Fonts (Poppins) et des icônes FluentUI pour une esthétique moderne.
