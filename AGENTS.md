# Repository Guidelines

## Project Structure & Module Organization
`src/` contains all runtime code: `App.tsx` hosts state and layout, `index.tsx` boots React, and shared UI lives in `src/components/` with types in `src/types.ts`. Build artifacts land in `dist/` (gitignored). Key configs (`vite.config.ts`, `tsconfig*.json`) enforce strict TypeScript rules and the GitHub Pages base path.

## Build, Test, and Development Commands
- `npm install` – install dependencies.
- `npm run dev` – launch Vite (http://localhost:5173) with live reload and type diagnostics.
- `npm run build` – emit the production bundle to `dist/`; run before publishing.
- `npm run preview` – serve the built assets locally.
- `npm run deploy` – build + deploy to GitHub Pages via `gh-pages`.

## Configuration & API Access
- Development requests are proxied to `https://liveamcore1.waferlock.com:10001` through `/__waferlock`; leave `VITE_API_BASE_URL` unset so fetches stay relative and CORS-safe.
- Override the proxy target in dev with `VITE_PROXY_TARGET`; for other environments set `VITE_API_BASE_URL` to the desired origin.
- Production builds call the remote host directly, so the API must grant CORS access to the deployed origin or sit behind a matching reverse proxy.

## Coding Style & Naming Conventions
Use React function components with PascalCase filenames and default exports. Keep derived hooks beside their components and place reusable interfaces in `src/types.ts`. Follow the existing two-space indentation, semicolons, and strict TypeScript types. Styling is composed with Tailwind-like utility tokens (`bg-background`, `text-brand-primary`) rather than custom CSS.

## Testing Guidelines
Automated tests are not yet configured. Manually exercise flows in `npm run dev`, confirm `npm run build` succeeds, and document manual checks in PRs. New suites should live under `src/__tests__/` and use Vitest or React Testing Library with `<Component>.test.tsx` naming.

## Commit & Pull Request Guidelines
Adopt Conventional Commits (`feat:`, `fix:`, etc.) and keep each message scoped and imperative. PRs should explain the change, link any issue, and include screenshots for UI updates. Verify `npm run build` and `npm run preview` before requesting review.

## Security & Configuration Tips
Keep secrets (e.g., `GEMINI_API_KEY`, LiveAM credentials) in `.env.local` only. Continue sanitizing API responses as in `App.tsx`, and avoid hard-coding alternative hosts unless they are configurable.
