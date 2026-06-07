const GITHUB_URL = "https://github.com/Alvish0407/clautter";

export default function Footer() {
  return (
    <footer className="border-t-2 border-ink">
      <div className="mx-auto flex max-w-[1200px] flex-col items-start justify-between gap-4 px-5 py-9 sm:flex-row sm:items-center sm:px-8">
        <p className="text-[14px] font-medium text-muted">
          Clautter — Claude <span className="text-claude">×</span>{" "}
          <span className="text-flutter">Flutter</span>. Open-source
          interactive animations.
        </p>
        <a
          href={GITHUB_URL}
          target="_blank"
          rel="noreferrer"
          className="rounded-btn border-2 border-ink bg-surface px-3.5 py-1.5 text-[13px] font-bold text-ink shadow-hard-sm transition-transform duration-150 hover:-translate-x-0.5 hover:-translate-y-0.5"
        >
          View source →
        </a>
      </div>
    </footer>
  );
}
