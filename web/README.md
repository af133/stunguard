# 🛡️ StunGuard Web

Frontend aplikasi **StunGuard**, sebuah platform keamanan digital berbasis web yang dikembangkan menggunakan React, TypeScript, dan Vite. Aplikasi ini berfungsi sebagai antarmuka pengguna untuk berinteraksi dengan layanan backend StunGuard, seperti autentikasi, manajemen pengguna, serta fitur-fitur keamanan lainnya.

## 🚀 Tech Stack

- React 19
- TypeScript
- Vite
- React Router DOM
- Tailwind CSS
- shadcn/ui
- Axios
- ESLint

---

## 📁 Project Structure

```text
web/
├── public/
├── src/
│   ├── assets/          # Images, icons, fonts
│   ├── components/      # Reusable UI components
│   ├── hooks/           # Custom React hooks
│   ├── layouts/         # Application layouts
│   ├── lib/             # Utility functions
│   ├── pages/           # Application pages
│   ├── routes/          # Routing configuration
│   ├── services/        # API communication
│   ├── types/           # TypeScript types/interfaces
│   ├── App.tsx
│   └── main.tsx
├── package.json
├── vite.config.ts
└── README.md
```

---

## ⚙️ Getting Started

### 1. Clone Repository

```bash
git clone https://github.com/your-username/stunguard.git
```

### 2. Navigate to Frontend

```bash
cd stunguard/web
```

### 3. Install Dependencies

```bash
npm install
```

### 4. Run Development Server

```bash
npm run dev
```

The application will be available at:

```
http://localhost:5173
```

---

## 🔧 Available Scripts

### Start Development Server

```bash
npm run dev
```

### Build Production

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

### Lint Project

```bash
npm run lint
```

---

## 🌐 Environment Variables

Create a `.env` file in the project root.

```env
VITE_API_URL=http://localhost:8080/api
```

Example usage:

```ts
const API_URL = import.meta.env.VITE_API_URL;
```

---

## 🔗 Backend

This frontend communicates with the **StunGuard Backend API**.

Default backend address:

```
http://localhost:8080
```

---

## ✨ Features

- User Authentication
- JWT-based Authorization
- Responsive User Interface
- Modern Component Library
- Secure API Integration
- Type-safe Development
- Fast Development Experience with Vite

---

## 📦 Production Build

```bash
npm run build
```

Generated files will be located in:

```
dist/
```

---

## 🧑‍💻 Development Guidelines

- Use TypeScript for all components.
- Prefer reusable UI components.
- Keep business logic inside hooks or services.
- Separate API requests from UI.
- Follow ESLint rules.
- Use environment variables for configuration.

---

## 📄 License

This project is licensed under the MIT License.

---

Developed with ❤️ by the StunGuard Team.