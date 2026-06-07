export default function Hero() {
  return (
    <section className="relative overflow-hidden border-b-2 border-ink">
      <div className="relative mx-auto max-w-[1200px] px-5 py-16 sm:px-8 sm:py-24">
        <span className="animate-rise inline-block rounded-full border-2 border-ink bg-surface px-3.5 py-1.5 text-[13px] font-bold text-ink shadow-hard-sm">
          Claude <span className="text-claude">×</span>{" "}
          <span className="text-flutter">Flutter</span>
        </span>

        <h1 className="animate-rise mt-6 max-w-[14ch] font-display text-[44px] leading-[0.98] tracking-[-0.03em] text-ink sm:text-[78px]">
          Animations you can{" "}
          <span className="text-flutter">actually</span> play with.
        </h1>

        <p className="animate-rise mt-6 max-w-[54ch] text-[17px] font-medium leading-relaxed text-muted sm:text-[19px]">
          A living collection of interactive animations, built entirely in
          code. No videos, no images — open one and drag, hover and move your
          cursor to watch it respond in real time.
        </p>
      </div>
    </section>
  );
}
