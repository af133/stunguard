import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';

export type UserRole = 'petugas_puskesmas' | 'admin_dinkes';

export interface User {
  id: string;
  nama: string;
  role: UserRole;
  wilayah: string;
  avatar: string;
}

interface AuthContextType {
  user: User | null;
  login: (role: UserRole) => void;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const defaultUser: User = {
  id: 'U01',
  nama: 'Dr. Siti Aminah',
  role: 'petugas_puskesmas',
  wilayah: 'Puskesmas Caringin',
  avatar: 'SA',
};

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(() => {
    const saved = localStorage.getItem('stuntguard_user');
    return saved ? JSON.parse(saved) : defaultUser;
  });

  useEffect(() => {
    if (user) {
      localStorage.setItem('stuntguard_user', JSON.stringify(user));
    } else {
      localStorage.removeItem('stuntguard_user');
    }
  }, [user]);

  const login = (role: UserRole) => {
    const newUser: User = {
      id: role === 'admin_dinkes' ? 'U02' : 'U01',
      nama: role === 'admin_dinkes' ? 'Drs. H. Bambang S.' : 'Dr. Siti Aminah',
      role,
      wilayah: role === 'admin_dinkes' ? 'Dinas Kesehatan Kab. Bogor' : 'Puskesmas Caringin',
      avatar: role === 'admin_dinkes' ? 'BS' : 'SA',
    };
    setUser(newUser);
  };

  const logout = () => {
    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        login,
        logout,
        isAuthenticated: !!user,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
