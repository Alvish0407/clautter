import Link from "next/link";

export default function NotFound() {
  return (
    <div className="grid min-h-screen place-items-center px-6">
      <div className="text-center">
        <p className="text-[14px] font-bold uppercase tracking-[0.18em] text-flutter">
          404
        </p>
        <h1 className="mt-3 font-display text-[34px] leading-none tracking-[-0.02em] text-ink sm:text-[48px]">
          Can&rsquo;t find that one.
        </h1>
        <p className="mt-3 text-[16px] font-medium text-muted">
          It might have moved, or maybe it never existed. Let&rsquo;s get you
          back.
        </p>
        <Link
          href="/"
          className="mt-7 inline-flex rounded-btn border-2 border-ink bg-flutter px-5 py-2.5 text-[14px] font-bold text-accent-ink shadow-hard transition-transform duration-150 hover:-translate-x-0.5 hover:-translate-y-0.5 active:translate-x-0 active:translate-y-0"
        >
          Back to gallery
        </Link>
      </div>
    </div>
  );
}
