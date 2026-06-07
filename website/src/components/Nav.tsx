import Link from "next/link";
import Logo from "./Logo";

const GITHUB_URL = "https://github.com/Alvish0407/clautter";

export default function Nav({ count }: { count: number }) {
  return (
    <header className="sticky top-0 z-50 border-b-2 border-ink bg-bg/85 backdrop-blur-md">
      <div className="mx-auto flex h-[68px] max-w-[1200px] items-center justify-between px-5 sm:px-8">
        <Link href="/" className="flex items-center gap-2.5">
          <Logo size={36} />
          <span className="font-display text-[24px] leading-none tracking-[-0.02em] text-ink">
            Clautter
          </span>
        </Link>

        <nav className="flex items-center gap-2.5">
          <span className="hidden rounded-btn border-2 border-ink bg-surface px-3 py-1.5 text-[13px] font-bold text-ink shadow-hard-sm sm:inline">
            {count} {count === 1 ? "animation" : "animations"}
          </span>
          <a
            href={GITHUB_URL}
            target="_blank"
            rel="noreferrer"
            className="rounded-btn border-2 border-ink bg-claude px-3.5 py-1.5 text-[13px] font-bold text-ink shadow-hard-sm transition-transform duration-150 hover:-translate-x-0.5 hover:-translate-y-0.5 active:translate-x-0 active:translate-y-0"
          >
            GitHub
          </a>
        </nav>
      </div>
    </header>
  );
}
