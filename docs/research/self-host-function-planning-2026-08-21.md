# Self-host function planning

Date: 2026-08-21

The Dew compiler now plans local callable ABI metadata.

Implemented behavior:

- builtin, foreign, ordinary function, trait method, and implementation method kinds;
- declaration-to-callable lookup slots;
- source parameter IDs, indexes, receiver flags, resolved types, and backend shapes;
- owner and callable generic spans;
- implementation `Self` substitution for parameter and result representation shapes;
- generic trait `Self` shapes;
- visibility and compiler-owned classification;
- test-only, test-entry, display-name, body, and source-offset metadata.

A Starshine `heap2local` validation defect was isolated to matching the large `SelfHostCollectedDeclarationReference` result inside compiler-shaped callable construction. The planner avoids that unsafe temporary by scanning the compact top-level and method arenas directly. Current Dew assembly does not run Starshine module optimization; self-host artifacts are validated, unoptimized debug modules.
