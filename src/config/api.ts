// Konfigurasi API terpusat
// Ubah VITE_API_URL di file .env untuk switch antara backend lokal dan staging
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080/api';

export default API_URL;
