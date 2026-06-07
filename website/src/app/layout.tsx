import type { Metadata } from "next";
import { Bagel_Fat_One, Geist } from "next/font/google";
import "./globals.css";

const geist = Geist({
  subsets: ["latin"],
  variable: "--font-geist",
  display: "swap",
});

const bagel = Bagel_Fat_One({
  weight: "400",
  subsets: ["latin"],
  variable: "--font-bagel",
  display: "swap",
});

export const metadata: Metadata = {
  title: "Clautter — interactive animations, built in code",
  description:
    "Claude × Flutter. A living collection of interactive animations, built entirely in code. Open any piece and play with it.",
  openGraph: {
    title: "Clautter — interactive animations, built in code",
    description:
      "A living collection of interactive animations, built entirely in code.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${geist.variable} ${bagel.variable} h-full`}>
      <body className="min-h-full">{children}</body>
    </html>
  );
}
