![Quiz App Banner](client/assets/quizappBanner.png)

# QuizApp - Your Ultimate Quiz Experience Platform

QuizApp is a dynamic and engaging application designed to provide a comprehensive platform for creating, sharing, and playing quizzes. Whether you're looking to challenge yourself, learn something new, or have fun with friends, QuizApp has you covered with its intuitive and feature-rich interface.

---

## Table of Contents

- [Concept of QuizApp](#concept-of-quizapp)
- [Purpose of QuizApp](#purpose-of-quizapp)
  - [Creative Freedom with Quiz Creation](#creative-freedom-with-quiz-creation)
  - [Solo and Multiplayer Quiz Modes](#solo-and-multiplayer-quiz-modes)
  - [Real-Time Engagement](#real-time-engagement)
  - [Enhanced Community Experience](#enhanced-community-experience)
- [Why QuizApp is Essential](#why-quizapp-is-essential)
  - [Learning Made Fun](#learning-made-fun)
  - [Social Connection](#social-connection)
  - [Creative Outlet](#creative-outlet)
  - [Convenience](#convenience)
  - [Future-Ready](#future-ready)
- [Built With](#built-with)
- [Startup](#startup)
  - [.env Variables](#env-variables)
  - [env Example](#env-example)
  - [Generate a JWT_SECRET Securely](#to-generate-a-jwt_secret-securely)
  - [Properties Example](#properties-example)
- [Code Contributors](#code-contributors)

---

## Concept of QuizApp

QuizApp revolutionizes the way users interact with quizzes by offering both solo and multiplayer experiences. The application enables users to create custom quizzes and explore a rich library of community-generated quizzes, catering to all interests and difficulty levels.

---

## Purpose of QuizApp

### **Creative Freedom with Quiz Creation**

- Build your own quizzes with ease using our intuitive interface.
- Add titles, questions, multiple-choice answers, time limits, and hints for a fully personalized experience.

### **Solo and Multiplayer Quiz Modes**

- **Solo Mode:** Test your knowledge independently and compete against your own high scores.
- **Multiplayer Mode:** Host quiz challenges with friends for a social, competitive experience.

### **Real-Time Engagement**

- Real-time score updates in multiplayer mode make every game thrilling and competitive.
- Create private quiz lobbies to share and enjoy quizzes with ease.

### **Enhanced Community Experience**

- Explore quizzes created by others in our Community Quizzes Section.
- Browse by topic, difficulty, or popularity, and join a vibrant community of quiz enthusiasts.

---

## Why QuizApp is Essential

### **Learning Made Fun**

- QuizApp transforms learning into an interactive and enjoyable activity, helping users expand their knowledge on a variety of topics.

### **Social Connection**

- Engage with friends through multiplayer mode, making quizzes a fun and shared experience.

### **Creative Outlet**

- Express your creativity by designing unique quizzes and sharing them with the community.

### **Convenience**

- Skip the hassle of manually organizing quizzes. QuizApp offers streamlined quiz creation, hosting, and real-time results.

### **Future-Ready**

- With upcoming features like personalized profile settings, improved UI/UX, and leaderboards, QuizApp is constantly evolving to enhance the user experience.

### Built With

- [![Next][Next.js]][Next-url]
- [![Flutter][Flutter.js]][Flutter-url]
- [![SQL][Sql.js]][Sql-url]

# Startup

## .env variables

```ini
SERVER_PORT =

DATABASE_URL = {REQUIRED}
DATABASE_USERNAME = {REQUIRED}
DATABASE_PASSWORD =
DATABASE_DRIVER = {REQUIRED}

KEY_NAME = {Required if USE_SSL is true}
CERT_PASS = {Required if USE_SSL is true}
USE_SSL = false

ADMIN_USER = {REQUIRED}
ADMIN_PASS = {REQUIRED}

JWT_SECRET = {Required}
```

### env example>

```ini
SERVER_PORT = 8080

DATABASE_URL = jdbc:mysql://localhost:3306/mobilapp
DATABASE_USERNAME = root
DATABASE_PASSWORD =
DATABASE_DRIVER = com.mysql.cj.jdbc.Driver

KEY_NAME = {Required if USE_SSL is true}
CERT_PASS = {Required if USE_SSL is true}
USE_SSL = false

ADMIN_USER = You create a username
ADMIN_PASS = You create a password

JWT_SECRET = {Required}
```

### To generate a JWT_SECRET securely

```bash
openssl rand -base64 32
```

## properties example:

```ini
spring.servlet.multipart.max-file-size=4MB
spring.servlet.multipart.max-request-size=4MB
server.error.include-message=always
server.port=${SERVER_PORT}

spring.datasource.url=${DATABASE_URL}
spring.datasource.username=${DATABASE_USERNAME}
spring.datasource.password=${DATABASE_PASSWORD}
spring.datasource.driver-class-name=${DATABASE_DRIVER}

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

spring.config.import=optional:file:.env[.properties]

server.ssl.certificate=${KEY_NAME}
server.ssl.certificate-private-key=${CERT_PASS}
server.ssl.enabled=${USE_SSL}

spring.security.user.name=${ADMIN_USER}
spring.security.user.password=${ADMIN_PASS}

spring.jpa.open-in-view=false

spring.output.ansi.enabled=always

jwt.secret=${JWT_SECRET}
```

## Running Backend with Docker

The easiest way to get the backend up and running is using Docker. This method will automatically set up both the MySQL database and the Spring Boot backend application.

### Prerequisites
- Docker and Docker Compose installed on your system
- Git (to clone the repository)

### Steps to Run

1. Navigate to the server directory:
```bash
cd server
```
2. Start the application using Docker Compose:
```bash
docker compose up
```

This command will:

- Pull two Docker images:

  - MySQL latest version (database)
  - jannordskog/springapimobilapp:latest (backend API)


- Create and configure the necessary volumes for data persistence
- Set up the required network connections
- Start both services with the correct configuration

The backend API will be available at:

http://localhost:8080 (or your machine's IP address:8080)

### Verifying the Setup
You can check if both services are running properly using:
```bash
docker compose ps
```
To view the logs:
```bash
docker compose logs
```
To stop the services:
```bash
docker compose down
```

Note: When you run docker compose down, the database data will persist thanks to the volume configuration. If you want to completely reset everything, you can use:

```bash
docker compose down -v
```

### Updating Docker Image

When you make changes to the backend code, follow these steps to update the Docker image:

1. Build a new version of your Docker image:
```bash
docker build -t jannordskog/springapimobilapp:latest .
```
2. Push the updated image to Docker Hub:
```bash
docker login
docker push jannordskog/springapimobilapp:latest
```
3. If your containers are running, stop them:
```bash
docker compose down
```
4. Pull the latest version and restart:
```bash
docker compose pull
docker compose up
```
Alternatively, you can do a one-line update and restart:
```bash
docker compose down && docker compose pull && docker compose up
```
Note: Make sure you're logged into Docker Hub with an account that has permission to push to the jannordskog repository.
## Code Contributors

This project exists thanks to the contributions from our development team:

- 👤 **Rune Molander** (Project/Engineer Manager, Lead Programmer [Frontend, Backend], Software architect, Database architect, Feature designer, QA)
- 👤 **Jan Christian Nordskog** (Lead UI/UX Designer, Programmer [Frontend, Backend])
- 👤 **Phillip** (Programmer [Frontend, Backend], UI/UX Designer)
- 👤 **Avnit** (Programmer [Frontend, Backend], Database developer, QA Engineer)

[Next.js]: https://img.shields.io/badge/Spring-6DB33F?style=for-the-badge&logo=spring&logoColor=white
[Next-url]: https://spring.io/
[Flutter.js]: https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=fff&style=for-the-badge
[Flutter-url]: https://flutter.dev/
[Sql.js]: https://img.shields.io/badge/MySQL-00000F?style=for-the-badge&logo=mysql&logoColor=white
[Sql-url]: https://www.mysql.com/
