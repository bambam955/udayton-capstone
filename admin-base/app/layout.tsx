import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Biz Rush Admin",
  description: "Biz Rush operations center dashboard."
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        <div className="relative min-h-screen overflow-hidden bg-[color:var(--bg)] text-white">
          <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(1,117,194,0.2),_transparent_55%)]" />
          <div className="pointer-events-none absolute -top-24 right-[-10%] h-72 w-72 rounded-full bg-[rgba(1,117,194,0.24)] blur-[120px]" />
          <div className="pointer-events-none absolute bottom-0 left-[-15%] h-80 w-80 rounded-full bg-[rgba(57,162,255,0.16)] blur-[140px]" />
          <div className="relative z-10">{children}</div>
        </div>
      </body>
    </html>
  );
}
