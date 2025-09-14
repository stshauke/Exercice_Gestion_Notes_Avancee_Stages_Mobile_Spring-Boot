"# Exercice_Gestion_Notes_Avancee_Stages_Mobile_Spring-Boot" 

# Notes Suite

**Notes Suite** est une application de prise de notes collaborative composée de trois parties :

- **Backend** : API REST construite avec **Spring Boot** et **PostgreSQL**  
- **Frontend Web** : interface utilisateur en **React.js (Vite + Tailwind)**  
- **Mobile** : application **Flutter** consommant la même API  

---

##  Prérequis

Avant de commencer, assure-toi d’avoir installé :

- [Docker](https://docs.docker.com/get-docker/) (≥ 20.x)  
- [Docker Compose](https://docs.docker.com/compose/install/)  
- [Java 21+](https://adoptium.net/) (si tu veux lancer Spring Boot hors Docker)  
- [Maven](https://maven.apache.org/)  
- [Node.js](https://nodejs.org/) (≥ 18.x) + [npm](https://www.npmjs.com/) ou [yarn](https://yarnpkg.com/)  
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (≥ 3.x)  

---

## Lancer l’application en local

### 1. Cloner le dépôt
```bash
git clone https://github.com/stshauke/Exercice_Gestion_Notes_Avancee_Stages_Mobile_Spring-Boot.git
cd notes-suite


### 2. Lancer PostgreSQL avec Docker

Dans le dossier backend-spring :

docker run --name notes-pg \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=notes \
  -p 5432:5432 \
  -d postgres:16-alpine

Vérifie que le conteneur tourne : docker ps

### 3. Lancer le Backend Spring Boot

Toujours dans backend-spring/ : mvn clean spring-boot:run

### 4. Lancer le Frontend React.js

Dans le dossier frontend-react/ :

npm install     # ou yarn
npm run dev     # ou yarn dev

### 5. Lancer l’application Flutter

Dans le dossier frontend-flutter/ :

flutter pub get
flutter run

### 6. Tâches réalisées 

CRUD complet pour les notes (création, édition, suppression)
Partage privé des notes avec d’autres utilisateurs
Partage public via un lien unique
Page Notes partagées avec moi
Recherche par titre et par contenu des notes
Interfaces Web (React) et Mobile (Flutter)
Authentification (JWT) et gestion des rôles (Utilisateur / Admin)