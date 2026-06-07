/**
 * Clautter mark — Claude (coral) → Flutter (blue) gradient square with a crisp
 * "C", framed in the neo-brutalist ink border. Matches /app/icon.svg.
 */
export default function Logo({ size = 36 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 100 100"
      aria-hidden
      className="shrink-0"
    >
      <defs>
        <linearGradient id="clautter-logo" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#D97757" />
          <stop offset="1" stopColor="#027DFD" />
        </linearGradient>
      </defs>
      <rect
        x="7"
        y="7"
        width="86"
        height="86"
        rx="24"
        fill="url(#clautter-logo)"
        stroke="#151617"
        strokeWidth="6"
      />
      <path
        d="M68 33 A22 22 0 1 0 68 67"
        fill="none"
        stroke="#fff"
        strokeWidth="12"
        strokeLinecap="round"
      />
    </svg>
  );
}
