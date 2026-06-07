import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import EmbedFrame from "@/components/EmbedFrame";
import { getProject, projects, embedUrl } from "@/lib/projects";

export function generateStaticParams() {
  return projects.map((p) => ({ id: p.id }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>;
}): Promise<Metadata> {
  const { id } = await params;
  const project = getProject(id);
  if (!project) return { title: "Not found · Clautter" };
  return {
    title: `${project.title} · Clautter`,
    description: project.blurb,
  };
}

export default async function WorkPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const project = getProject(id);
  if (!project) notFound();

  return (
    <div className="flex min-h-screen flex-col">
      <Nav count={projects.length} />

      <main className="mx-auto w-full max-w-[1200px] flex-1 px-5 py-8 sm:px-8 sm:py-12">
        {/* Breadcrumb / header */}
        <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
          <div>
            <Link
              href="/"
              className="inline-flex items-center gap-1.5 text-[13px] font-bold text-muted transition hover:text-flutter"
            >
              ← Gallery
            </Link>
            <h1 className="mt-2 font-display text-[30px] leading-none tracking-[-0.02em] text-ink sm:text-[44px]">
              {project.title}
            </h1>
          </div>
          <a
            href={embedUrl(project.id)}
            target="_blank"
            rel="noreferrer"
            className="rounded-btn border-2 border-ink bg-flutter px-4 py-2 text-[13px] font-bold text-accent-ink shadow-hard-sm transition-transform duration-150 hover:-translate-x-0.5 hover:-translate-y-0.5 active:translate-x-0 active:translate-y-0"
          >
            Open standalone ↗
          </a>
        </div>

        {/* The live, interactive embed */}
        <EmbedFrame
          src={embedUrl(project.id)}
          title={project.title}
          bg={project.previewBg}
          dark={project.dark}
        />

        {/* Details */}
        <div className="mt-10 grid grid-cols-1 gap-10 lg:grid-cols-[1.4fr_1fr]">
          <div>
            <h2 className="font-display text-[22px] leading-none tracking-[-0.01em] text-ink">
              About
            </h2>
            <p className="mt-4 text-[16px] font-medium leading-relaxed text-muted">
              {project.description}
            </p>
            <div className="mt-5 flex flex-wrap gap-2">
              {project.tags.map((tag) => (
                <span
                  key={tag}
                  className="rounded-chip border-2 border-ink bg-surface px-2.5 py-1 text-[12px] font-bold text-ink"
                >
                  {tag}
                </span>
              ))}
            </div>
          </div>

          <div>
            <h2 className="font-display text-[22px] leading-none tracking-[-0.01em] text-ink">
              Techniques
            </h2>
            <ul className="mt-4 space-y-2.5">
              {project.techniques.map((t) => (
                <li
                  key={t}
                  className="flex items-start gap-2.5 text-[14.5px] font-medium text-ink"
                >
                  <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-flutter ring-2 ring-ink" />
                  {t}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
