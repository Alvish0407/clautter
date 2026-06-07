import Nav from "@/components/Nav";
import Hero from "@/components/Hero";
import Footer from "@/components/Footer";
import ProjectCard from "@/components/ProjectCard";
import { projects } from "@/lib/projects";

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col">
      <Nav count={projects.length} />
      <main className="flex-1">
        <Hero />
        <section
          id="gallery"
          className="mx-auto max-w-[1200px] px-5 py-14 sm:px-8 sm:py-20"
        >
          <div className="mb-8 flex items-baseline justify-between">
            <h2 className="font-display text-[28px] leading-none tracking-[-0.02em] text-ink">
              Gallery
            </h2>
            <span className="text-[14px] font-bold text-muted">
              {projects.length} pieces
            </span>
          </div>
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {projects.map((project) => (
              <ProjectCard key={project.id} project={project} />
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </div>
  );
}
