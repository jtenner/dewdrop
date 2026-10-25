# Daybreak Blue reviews in local Codex

The exact model ID is `gpt-daybreak-blue-latest`. Local Codex0.163.0 lists it
as Daybreak Blue with `visibility:list`, API support, and available Cyber
program `daybreak_blue`. The catalog is `/home/dev/.codex/models_cache.json`.
The separate OpenCode provider list did not list it. The short name
`daybreak-blue` is not a supported agent model ID; the exact ID works.

For a read-only Codex CLI session:

```sh
codex exec --model gpt-daybreak-blue-latest --sandbox read-only "Review the current code changes."
```

Local `codex exec --help` also exposes `--cyber-access-program daybreak_blue`.
This selects the access program separately from the model and requires account
access. That flag is not supported with the dedicated `review` subcommand in
this CLI, so an explicit-program review should use `exec` with a review prompt.
No default model or account configuration was changed.

OpenAI's [model page](https://developers.openai.com/api/docs/models/gpt-daybreak-blue-latest)
confirms the exact alias and marks it deprecated. The alias is still present
in this local account's current catalog and was used as explicitly requested.
The [Daybreak guide](https://developers.openai.com/api/docs/guides/daybreak)
documents model/program selection and account access as separate requirements.

The `gpt-daybreak-blue-latest` agent completed independent read-only reviews of
the array-cast/read fusion and the refined Old-descriptor candidate. Both report
no defects, with test gaps recorded separately. Reviews completed before public
delivery. The array fusion was subsequently pushed to PR948 and installed;
the Old-descriptor candidate is held because its full-job result is inconclusive.
Daybreak also reviewed the fold-only descriptor and bounded trapping-guard
candidates independently and found no defects; their full compiler checks
remain separate from source review.

## Supported current-model second review

The preferred path avoids the deprecated alias. Daybreak Blue is selected as
an access program, separately from a current model. Use a different reviewer
model (`gpt-6-sol` here, versus root `gpt-6.1-sol`) and request Blue explicitly:

```sh
codex exec --model gpt-6-sol --cyber-access-program daybreak_blue --sandbox read-only "Review the code changes. Check correctness, GC safety, and tests. Do not edit files."
```

The local CLI accepts this flag; the account/project must have access. Use an
`exec` review prompt because this CLI does not support the flag with its
`review` subcommand. The collaboration agent tool exposes a model selector
but no Cyber access-program selector, so the CLI is the explicit route. Do not
infer the selected access program from a model name. The current official guide
lists GPT-6 Sol with `daybreak_blue`; GPT-6.1 Sol/Astra need separate Red approval
for reduced-refusal access even though the request value stays Blue.

A read-only independent CLI review of the folded-space and trapping-guard
candidates was started with exactly this model/program pair. It runs no builds
or tests while compiler timing runs are active. Request/results are retained
under `.tmp/wago-next-gc-perf/daybreak-blue-current-review/`.

The current-model CLI review completed in91.614s; a limited recheck completed in
11.177s. Both exit0. Saved Codex turn_context records explicitly show
`model:gpt-6-sol` and `cyber_access_program:daybreak_blue` for both turns. No
concrete defects were found. The reviewer withdrew one initial test-gap claim
on recheck because the planner already requires unreachable before its tail
loop. Its remaining gaps are per-resolver dirty pin trap coverage and successful
reuse with each R12–R14 register. No code or account configuration changed as
part of this research.
