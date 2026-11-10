# Preserve the desktop app while customizing it

Before editing, read the installed app home's `AGENTS.md` and the relevant generated `herdr.d.ts` / `gpui-kit.d.ts`. The home is `${HERDR_APP_HOME:-$HOME/.config/herdr-app}`. These files describe the installed version and are rewritten on startup; never store persistent skill changes in them.

Inspect existing files and modify only the requested settings. A skill update is not permission to migrate the user's live app configuration.

## Layouts, keys, and mods

- Keep app settings in `settings.json`, keys in `keys.json`, personal layouts under `layouts/`, and mods under `mods/<name>/`. Do not copy TUI `config.toml` wholesale: its schema and action names differ. For a requested key migration, map individual actions using `herdr-app commands`, preserve existing app bindings/sections, and check conflicts and key scope in the installed guide.
- Clone shipped mods with `mod.clone` before editing their code, and shipped layouts with `layout.clone` before structural changes. Confirm arguments with `herdr-app commands`. Cloning a layout also switches the view; account for that visible effect. Look-only settings can use the supported settings/theme controls.
- Mods are native gpui-kit JavaScript, not a browser: no DOM, CSS, Node APIs, or timer-based UI assumptions. Read the generated types. Use theme colors and native animation; each callback uses its own `cx`, never a retained one.
- Keep `mod.json` capabilities, focus handling, pane props, overlays, async behavior, and cleanup that the requested change does not affect. A mod pane has its own identity and can coexist with terminal panes.
- Structural state is stored in the core's app document. Use commands for spaces/tabs/panes, not invented `spaces.json` files or direct edits to app-written state. Preserve `view.json`, shared/mod data, bookkeeping, and generated `frame/` content unless their change is specifically requested.

## Verify the actual change

Edits hot-reload. A broken file leaves the last good version visible, so a working window alone proves nothing. Inspect `herdr-app status` and the relevant `.error` file after each edit.

For a changed mod:

```sh
herdr-app check <absolute-mod-directory>
herdr-app status
herdr-app shot /tmp/herdr-mod-review.png
```

Require a passing `check`, then inspect the captured image and exercise the relevant behavior in the app. `check` evaluates the initial description/eager elements; it does not prove deferred renders, later async states, or interactions. The app's `shot` captures its rendered frame, including overlays, even when covered/minimized; it requires a running window that has drawn a frame. Do not claim visual verification from the command's success alone.

For layouts/settings/keys, validate their JSON and reported errors, then verify the affected view/action. Preserve unrelated user customization. If no running app is available, report which visual or interaction checks remain unverified rather than starting one implicitly.

For app development experiments, the upstream app's `scripts/sandbox` provides an isolated home/core/display when available. Do not experiment with desktop pointer/key automation on the user's real display. Do not invoke `app.reset` or the escape hatch as a routine fix; they set aside the current layout and keys. `herdr-app feedback` opens a draft for the person to review/send and belongs only to a requested feedback task.
