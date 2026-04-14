type AdminHeaderProps = {
  title: string;
  subtitle?: string;
};

export default function AdminHeader({ title, subtitle }: AdminHeaderProps) {
  return (
    <div className="animate-fade-up border-b border-[rgba(255,255,255,0.08)] pb-6">
      <div>
        <h1 className="font-display text-2xl font-semibold text-white">
          {title}
        </h1>
        {subtitle ? (
          <p className="mt-1 text-sm text-[color:var(--text-muted)]">
            {subtitle}
          </p>
        ) : null}
      </div>
    </div>
  );
}
