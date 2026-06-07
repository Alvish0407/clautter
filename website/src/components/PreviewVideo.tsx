"use client";

import { useEffect, useRef } from "react";

type Props = {
  src: string;
  className?: string;
};

/**
 * Muted, autoplaying, looping preview clip. The `muted` property is set
 * imperatively because some browsers ignore the JSX attribute and then block
 * autoplay.
 */
export default function PreviewVideo({ src, className }: Props) {
  const ref = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    el.muted = true;
    el.play().catch(() => {
      /* autoplay may be blocked until interaction, which is harmless */
    });
  }, []);

  return (
    <video
      ref={ref}
      className={className}
      src={src}
      autoPlay
      muted
      loop
      playsInline
      preload="metadata"
    />
  );
}
