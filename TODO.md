# TODO — wla-dx

**Status markers:** `[ ]` open · `[wip]` in progress · `[verify]` implemented, verification
not yet run+recorded · `[x]` done (`## Done` only). The bracket also carries a delegation
tier, tier last — `[T4]`, `[wip T2]`, `[verify T3]`. See `~/CLAUDE.md` — Delegation.

## Open

_Nothing open._

## Watch

### Upstream PRs awaiting maintainer review

Three PRs were recorded as `[x]` done while their own text said **OPEN … awaiting
review**. Submitting a PR is not the same as landing it, and marking them done hid
three live threads. **Trigger:** when a maintainer merges or requests changes, move
the entry to `## Done` (merged) or back to `## Open` (changes requested, ranked then).

- [#723](https://github.com/vhelin/wla-dx/pull/723) — `mid()` integer overflow segfault (`fix/mid-integer-overflow`); +functions_error_test.
- [#724](https://github.com/vhelin/wla-dx/pull/724) — FORCE/OVERWRITE section labels in macros resolved to section start (`fix/macro-section-label-address`); +macro_section_label_test; cites breaking commit 44ca5c12.
- [#725](https://github.com/vhelin/wla-dx/pull/725) — `.REPT`/`.REPEAT` hang on an unexpected token (`fix/rept-infinite-loop`); +rept_error_test; cites breaking commit b44d8341.

## Parked

### Deliberately not submitted upstream

- `fix/sh2-uninitialized-warnings` — cosmetic; the maintainer reviews these himself.
- `fix/wlalink-duplicate-label-lastwins` — behavioural; left as a question for the maintainer, who has the review report. Both branches remain on the fork.

## Done

_Entries below are kept verbatim rather than condensed: each names the PR, branch and
regression test that constitute its evidence, and only the v10.7 group links a plan._

- [x] 2026-06-12 — [wla-dx-v10-7] v10.7 correctness fixes — 7 atomic branches pushed to fork `wbniv/wla-dx`, each fix+regression test, suite green; PR index in [docs/investigations/prs/README.md](docs/investigations/prs/README.md). See [plan](docs/plans/2026-06-12-wla-dx-v10-7-seven-correctness-fixes-as-atomic-pr.md) and [review](docs/investigations/2026-06-12-v10.6-to-v10.7-code-review.md).
- [x] **MERGED ([#720](https://github.com/vhelin/wla-dx/pull/720))** — `WLAVALRGIND`→`WLAVALGRIND` typo in 10 makefiles; wlalink now runs under Valgrind; 12/12 CI green; merged by maintainer.
- [x] **MERGED ([#721](https://github.com/vhelin/wla-dx/pull/721))** — eZ80 FD-page index loads emitted wrong register (`fix/ez80-fd-index-loads`); corrected 10 enshrined `@BT` tests.
- [x] **MERGED ([#722](https://github.com/vhelin/wla-dx/pull/722))** — MC68000 labels `S0`–`S7` parsed as A7 (`fix/68000-s-register-alias`); +sp_alias_test.
- [x] FORCE/OVERWRITE section labels in macros resolved to section start (`fix/macro-section-label-address`); +macro_section_label_test.
- [x] `mid()` signed overflow → SIGSEGV (`fix/mid-integer-overflow`); +functions_error_test (verified vs unpatched).
- [x] `.REPT 2 5` infinite hang (`fix/rept-infinite-loop`); +rept_error_test.
- [x] wlalink duplicate-label first-wins regression under `-c` (`fix/wlalink-duplicate-label-lastwins`); +duplicate_labels_lastwins (verified both ways).
- [x] 4 decode.c `-Wmaybe-uninitialized` warnings (`fix/sh2-uninitialized-warnings`); clean build, 0 warnings.
