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

const title = "Clautter · interactive animations built in code";
const description =
  "Little interactive animations, built in code. Open one and play with it.";

export const metadata: Metadata = {
  metadataBase: new URL("https://clautter.alvish.in"),
  title,
  description:
    "A bunch of little interactive animations I built in code. Open any one and play with it right in your browser.",
  openGraph: {
    title,
    description,
    type: "website",
    url: "https://clautter.alvish.in",
    siteName: "Clautter",
    images: [
      {
        url: "/og.png",
        width: 1200,
        height: 630,
        alt: "Clautter, a gallery of interactive animations built in code",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title,
    description,
    images: ["/og.png"],
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
