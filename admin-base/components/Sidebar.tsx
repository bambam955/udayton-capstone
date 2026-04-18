"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  { href: "/", label: "Dashboard" },
  { href: "/team", label: "Team" },
  { href: "/users", label: "Users" },
  { href: "/reports", label: "Reports" },
  { href: "/settings", label: "Settings" },
];

export default function Sidebar() {
  const pathname = usePathname();

  const isActive = (href: string) => {
    if (href === "/") return pathname === "/";
    return pathname === href || pathname.startsWith(`${href}/`);
  };

  return (
    <aside className="glass-card flex h-full w-full flex-col gap-6 rounded-3xl p-6">
      <div>
        <p className="font-display text-lg font-semibold text-white">Biz Rush Admin</p>
        <p className="mt-1 text-xs text-[color:var(--text-muted)]">Operations and oversight</p>
      </div>
      <nav className="flex flex-col gap-3 text-sm text-[color:var(--text-muted)]">
        {navItems.map((item) => {
          const active = isActive(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`rounded-xl border px-3 py-2 transition ${
                active
                  ? "border-[rgba(255,255,255,0.2)] bg-[rgba(255,255,255,0.08)] text-white"
                  : "border-transparent hover:border-[rgba(255,255,255,0.12)] hover:bg-[rgba(255,255,255,0.04)] hover:text-white"
              }`}
            >
              {item.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
