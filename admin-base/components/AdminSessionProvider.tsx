"use client";

import { createContext, useContext } from "react";

type AdminSession = {
  id: number;
  username?: string | null;
  email?: string | null;
  role?: string | null;
};

type AdminSessionProviderProps = {
  initialAdmin: AdminSession;
  children: React.ReactNode;
};

const AdminSessionContext = createContext<AdminSession | null>(null);

export function AdminSessionProvider({
  initialAdmin,
  children,
}: AdminSessionProviderProps) {
  return (
    <AdminSessionContext.Provider value={initialAdmin}>
      {children}
    </AdminSessionContext.Provider>
  );
}

export function useAdminSession() {
  return useContext(AdminSessionContext);
}
