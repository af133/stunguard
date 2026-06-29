# 🛡️ StunGuard

<p align="center">
  <img src="./assets/logo.png" width="180" alt="StunGuard Logo">
</p>

<p align="center">
A cross-platform application for detecting and monitoring child stunting using Artificial Intelligence.
</p>

---

# 📖 About

**StunGuard** is an AI-powered cross-platform application designed to assist in the early detection of stunting in children.

The project consists of three main applications:

- 🌐 **Web** — Dashboard for administrators and health workers.
- 📱 **Mobile** — Android application for users.
- ⚙️ **Backend API** — REST API built with Go (Gin Framework).

---

# 🏗 Project Structure

```text
stunguard/
│
├── backend/          # REST API (Go + Gin)
├── mobile/           # Flutter Application
├── web/              # React + Vite Application
├── model/            # AI Model
└── README.md
```

---

# 🚀 Getting Started

Clone this repository.

```bash
git clone https://github.com/USERNAME/stunguard.git
cd stunguard
```

---

# ⚙️ Backend Installation

Move to backend folder.

```bash
cd backend
```

### Install dependencies

```bash
go mod tidy
```

### Copy environment file

```bash
cp .env.example .env
```

Edit the `.env` file according to your configuration.

### Run API

```bash
go run ./cmd/api
```

or

```bash
air
```

Backend will run on

```
http://localhost:8080
```

---

# 🌐 Web Installation

Move to web folder.

```bash
cd web
```

Install dependencies.

```bash
npm install
```

Run development server.

```bash
npm run dev
```

Open

```
http://localhost:5173
```

---

# 📱 Mobile Installation

Move to mobile folder.

```bash
cd mobile
```

Install Flutter packages.

```bash
flutter pub get
```

Check Flutter installation.

```bash
flutter doctor
```

Run application.

```bash
flutter run
```

---

# 🤖 AI Model

The AI model is located inside

```
model/
```

This model is responsible for detecting stunting from uploaded images.

---

# 🛠 Technologies

## Backend

- Go
- Gin Framework
- PostgreSQL
- GORM
- JWT Authentication

## Web

- React
- TypeScript
- Vite
- TailwindCSS
- Shadcn UI

## Mobile

- Flutter
- Dart

## AI

- TensorFlow
- Python

---

# 📁 Environment Variables

Example backend `.env`

```env
PORT=8080

DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=stunguard

JWT_SECRET=your-secret-key
```

---

# 📡 API

Backend default endpoint

```
http://localhost:8080/api
```

Example

```
GET /api/health
POST /api/auth/login
POST /api/predict
```

---

# 🔄 Development Workflow

Clone repository

```bash
git clone https://github.com/USERNAME/stunguard.git
```

Install each project dependencies

```bash
backend/
go mod tidy

web/
npm install

mobile/
flutter pub get
```

Run each service separately.

Backend

```bash
go run ./cmd/api
```

Web

```bash
npm run dev
```

Mobile

```bash
flutter run
```

---

# 👨‍💻 Contributors

- Andre Firmansyah
- Team StunGuard

---

# 📄 License

This project is licensed under the MIT License.