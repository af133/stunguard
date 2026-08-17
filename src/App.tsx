import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './features/auth/AuthContext';
import ProtectedRoute from './features/auth/ProtectedRoute';
import RegisterPage from './features/auth/RegisterPage';
import LoginPage from './features/auth/LoginPage';
import DashboardPage from './features/dashboard/DashboardPage';
import PetaRisikoPage from './features/peta-risiko/PetaRisikoPage';
import DataAnakPage from './features/data-anak/DataAnakPage';
import DetailAnakPage from './features/data-anak/DetailAnakPage';
import PosyanduPage from './features/manajemen-posyandu/PosyanduPage';
import AlertPage from './features/alert/AlertPage';
import LaporanPage from './features/laporan/LaporanPage';
import AnalitikPage from './features/analitik/AnalitikPage';
import PengaturanPage from './features/pengaturan/PengaturanPage';

import './App.css';

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public Route */}
          <Route path="/" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />

          {/* Protected Routes */}
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <DashboardPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/peta-risiko"
            element={
              <ProtectedRoute>
                <PetaRisikoPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/data-anak"
            element={
              <ProtectedRoute>
                <DataAnakPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/data-anak/:id"
            element={
              <ProtectedRoute>
                <DetailAnakPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/posyandu"
            element={
              <ProtectedRoute>
                <PosyanduPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/alert"
            element={
              <ProtectedRoute>
                <AlertPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/laporan"
            element={
              <ProtectedRoute>
                <LaporanPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/analitik"
            element={
              <ProtectedRoute>
                <AnalitikPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/pengaturan"
            element={
              <ProtectedRoute>
                <PengaturanPage />
              </ProtectedRoute>
            }
          />

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
