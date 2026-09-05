# Agent Guidelines

- Use test-driven development where it is appropriate.
- Keep commits atomic, bounded, and easy to review.
- Adding tests that currently fail is acceptable; a failing suite is not itself a blocker.
- Do not write fail-closed tests. Failures must remain visible and diagnostic.
- Store research notes in `docs/research/*.md`.
- Update and organize documentation with every commit; keep it consistent with the implementation.
- Design for modularity and performance. Runtime performance is the highest priority, followed by a low memory footprint.
- Measure all compiler related activities as you do them. Things that take longer than half a minute should be considered bugs.
- Use runtime assertions in the compiler to validate type assumptions. Make assertion failures visible and diagnostic.
- Builtins are only for one-to-one WebAssembly instructions and explicit unsafe casts. Implement runtime algorithms in Dew library functions, and host calls with foreign declarations. Standard modules must use the same semantic and emission rules as user modules; do not dispatch on a standard module path, declaration ordinal, or source spelling.
- All versions and codecs are version 1. Dewdrop is not released yet, so breaking format changes do not break a released format.
- Use `tools/test-native.sh` for routine native tests. Use `tools/test-integration-native.sh` for complete compiler/backend integration cases, `tools/test-stress-native.sh` for large compiler stress tests, and `tools/test-starshine-native.sh` for the full pinned Starshine test suite. A raw workspace-wide `moon test` is not the routine Dewdrop lane.

## Done means done

Not half done. Not done except for the part you decided to skip. And not a report about how it will be done.

Five things asked means five things delivered, no matter how long they'll take. If the fifth is genuinely blocked, finish the other four and name the blocker in one sentence. The specific blocker. Not "this needs more investigation."

## Act. Don't ask.

Reversible and cheap? Do it, then tell me. Research, data pulls, analysis, drafts, refactors inside the scope I gave you, testing an API. A question costs me more than a re-run costs you.

Ask first only for: anything reaching an audience, anything we cannot undo, anything expensive.

Something is broken? Fix it. Reporting an issue you could have fixed turns your work into my to-do list.

## A question is a question

When I ask a question, answer it. Do not implement it.

"Should we use X?" is not "migrate everything to X." "What would it take to add Y?" is not "add Y."

When in doubt, assume it's a question. Answer first. Act when I say go.

## Short responses

It's been a long day and my brain is fried, talk to me like I'm 5.

Small words, short sentences, short paragraphs. If you have to use a big word, explain it right after. Only return what's actually necessary.

Just tell me what you did, did it work, what do I do now.

If I have to decide something: 2 options max, the context I need to pick fast, and which one you'd go with.

Keep paths and commands exact.

Always use ASD-STE100 Simplified Technical English when you talk to me.
