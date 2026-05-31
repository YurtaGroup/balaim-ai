# Sync this roadmap into AltaiOS (deferred)

**Status: deferred until AltaiOS Studios is on the live backend.**
Right now AltaiOS Studios ([AltaiOS/lib/features/studio/](../../../AltaiOS/lib/features/studio/)) consumes mock data from `core/providers/mock_data.dart`. Pushing Balam sprints into it would either (a) hardcode them as mock data (throwaway) or (b) require the live backend at github.com/TimurTMone/altai-os-backend to be deployed.

When the live backend ships, here's the recipe:

## Option A — Sync via the AltaiOS API (preferred)

1. Confirm `altai-os-backend` is deployed and `/api/os/projects` accepts POST.
2. The Balam PM agent runs:
   ```bash
   cd ~/Desktop/AppAltai/Balam.AI
   node scripts/sync_roadmap_to_altaios.js \
     --project="Balam — Sovereign Digital Childhood" \
     --source=docs/roadmap/SPRINTS.md \
     --target=https://altailabs.ai/api/os/projects
   ```
3. The script (to be written) parses `SPRINTS.md`, creates one project + one card per task with status, owner, acceptance criteria.

## Option B — One-shot import via mock_data.dart (throwaway, for demo)

1. Edit [AltaiOS/lib/core/providers/mock_data.dart](../../../AltaiOS/lib/core/providers/mock_data.dart) and add a `balamProject` block:
   ```dart
   final balamProject = Project(
     id: 'balam',
     name: 'Balam — Sovereign Digital Childhood',
     status: ProjectStatus.active,
     cards: [
       // Sprint 1 tasks
       Card(id: 'balam-1.1', title: 'Design Sunday Chapter Home card', column: 'backlog'),
       // ... etc
     ],
   );
   ```
2. Add it to `mockProjects` list.
3. Flutter hot-reload AltaiOS, navigate to `/projects/balam`.

## Option C — GitHub Projects sync (if you'd rather use github.com/users/TimurTMone/projects)

1. `gh project create --owner TimurTMone --title "Balam Roadmap"`
2. Script parses `SPRINTS.md` and creates one issue per task with the `balam` label.
3. Issues link back to `SPRINTS.md` as source-of-truth.

## When to flip the switch

Trigger this when:
- AltaiOS backend is live AND
- Timur wants the Balam roadmap visible alongside other AltaiLabs portfolio apps (Yurtah, AIbnb, etc.) for cross-project standups.

Until then: **`SPRINTS.md` is the source of truth.** The Balam PM agent edits it directly. No sync overhead, no two-sources-of-truth drift.
