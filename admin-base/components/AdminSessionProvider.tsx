"use client";

import { createContext, useContext } from "react";
import type { AdminSession } from "@/lib/api/types";

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
