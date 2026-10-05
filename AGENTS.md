# Stremio Enhanced

## Commands

- Install dependencies with `npm install` (the CI build uses Node 23 and Python for native-module rebuilds).
- `npm run dist` is the primary verification/build step: it runs `tsc` and then `copyComponents.js`.
- There is no test script or test runner configured. `npm run lint` targets `src/**/*.ts`, but currently fails after a standard install because the manifest does not declare `@typescript-eslint/eslint-plugin`; use `npm run dist` for actionable verification unless repairing the lint tooling.
- `npm run dev` rebuilds and launches Electron with detached DevTools. To debug without starting a streaming server, first run `npm run dist`, then use `npx electron ./dist/main.js --devtools --no-stremio-server`.
- Package with `npm run build:<platform>:<arch>` (for example, `npm run build:linux:x64`); artifacts go to `release-builds/`.
- `Formula/stremio-enhanced.rb` is the custom Homebrew formula. On a release, update its versioned source URL and SHA-256 with the app version; it deliberately builds the tagged source archive rather than the tap checkout.

## Source and runtime boundaries

- Edit `src/`, never `dist/` or `release-builds/`: both are generated/packaged output and ignored by Git.
- `src/main.ts` is the Electron main-process entrypoint. It loads `https://web.stremio.com/`; `src/preload/index.ts` injects the enhancement UI/behavior and exposes `window.StremioEnhancedAPI` through the context bridge.
- UI hooks in `src/preload/ui/` operate on the remote Stremio Web DOM. Keep its centralized selectors/classes in `src/constants/index.ts` in sync when changing those hooks; upstream Web UI changes can break them.
- Each `src/components/<name>/` pair contains TypeScript plus an HTML template. `copyComponents.js` copies every non-`.ts` component asset and the root `version` file into `dist/`; do not omit `npm run dist` after changing component HTML or `version`.
- Themes and plugins are external, user-supplied files, not repository source: they live under `stremio-enhanced/{themes,plugins}` in `%APPDATA%` (Windows), `~/Library/Application Support` (macOS), or `~/.config` (Linux). Their extensions are `.theme.css` and `.plugin.js`.

## Conventions

- TypeScript is strict with unused locals/parameters and implicit returns checked. Use tabs (width 4), matching the contribution guidance and existing source style.
