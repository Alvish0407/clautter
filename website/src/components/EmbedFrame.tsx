"use client";

import { useState } from "react";

type Props = {
  src: string;
  title: string;
  bg: string;
  dark: boolean;
};

export default function EmbedFrame({ src, title, bg, dark }: Props) {
  const [loaded, setLoaded] = useState(false);

  return (
    <div
      className="relative h-[70vh] min-h-[440px] w-full overflow-hidden rounded-card border-2 border-ink shadow-hard"
      style={{ backgroundColor: bg }}
    >
      {!loaded && (
        <div className="absolute inset-0 grid place-items-center">
          <div className="flex flex-col items-center gap-3">
            <span
              className={`h-7 w-7 animate-spin rounded-full border-2 border-t-transparent ${
                dark ? "border-white/60" : "border-ink/40"
              }`}
            />
            <span
              className={`text-[12px] font-medium ${
                dark ? "text-white/70" : "text-muted"
              }`}
            >
              Loading {title}…
            </span>
          </div>
        </div>
      )}
      <iframe
        src={src}
        title={title}
        onLoad={() => setLoaded(true)}
        className="h-full w-full border-0"
        allow="accelerometer; gyroscope; fullscreen"
      />
    </div>
  );
}
