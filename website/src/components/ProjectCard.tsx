import Link from "next/link";
import type { Project } from "@/lib/projects";
import PreviewVideo from "./PreviewVideo";

export default function ProjectCard({ project }: { project: Project }) {
  return (
    <Link
      href={`/work/${project.id}`}
      className="group block overflow-hidden rounded-card border-2 border-ink bg-surface shadow-hard transition-transform duration-150 ease-out hover:-translate-x-1 hover:-translate-y-1 hover:shadow-hard-lg active:translate-x-0 active:translate-y-0 active:shadow-hard-sm"
    >
      {/* Looping preview */}
      <div
        className="aspect-[16/10] w-full overflow-hidden border-b-2 border-ink"
        style={{ backgroundColor: project.previewBg }}
      >
        <PreviewVideo
          src={project.video}
          className="h-full w-full object-cover"
        />
      </div>

      {/* Title only */}
      <h3 className="px-5 py-4 text-[17px] font-bold tracking-[-0.01em] text-ink">
        {project.title}
      </h3>
    </Link>
  );
}
