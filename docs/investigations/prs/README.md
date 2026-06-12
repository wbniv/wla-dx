# v10.7 correctness fixes — pull requests

Eight atomic fix branches from the [v10.6→v10.7 review](../2026-06-12-v10.6-to-v10.7-code-review.md), each pushed to the fork [wbniv/wla-dx](https://github.com/wbniv/wla-dx). Every branch is cut from upstream `master` (`8e55b088`) and is independent, so the PRs can be opened, reviewed, and merged in any order.

**Three merged** — [#720](https://github.com/vhelin/wla-dx/pull/720) (typo), [#721](https://github.com/vhelin/wla-dx/pull/721) (eZ80), [#722](https://github.com/vhelin/wla-dx/pull/722) (68000), all 12 CI checks green. **Open:** [#723](https://github.com/vhelin/wla-dx/pull/723) (mid), [#724](https://github.com/vhelin/wla-dx/pull/724) (macro-label), [#725](https://github.com/vhelin/wla-dx/pull/725) (.REPT). The maintainer is engaged and receptive ("I've read that Fable 5 is really good!"). All five clear-cut fixes are now merged or open. The remaining two are **deliberately not submitted**: **sh2** (cosmetic — the maintainer will review it on his own) and **wlalink** (a behavioural change left as a question for the maintainer, who has a copy of the review report).

Each branch is a single commit whose message is written to serve as the PR body, so `gh pr create --fill` produces a complete PR. The branch contains **only** its source fix and regression test — the `docs/` review artifacts and `TODO.md` are kept on local `master` and are not pushed. AI assistance is credited the way this project already does it: an in-file `; NOTE: This test was created by Claude Fable 5.` comment in each added test, mirroring the existing `tests/*/all_instructions_test` suites — **no** `Co-Authored-By` commit trailer (the project's own AI-assisted commits don't use one).

## Open all eight PRs at once

From inside this repo (authenticated as `wbniv`, upstream `vhelin/wla-dx` already the `origin` remote):

```sh
for b in valgrind-variable-typo ez80-fd-index-loads 68000-s-register-alias macro-section-label-address \
         mid-integer-overflow rept-infinite-loop wlalink-duplicate-label-lastwins \
         sh2-uninitialized-warnings; do
  gh pr create --repo vhelin/wla-dx --base master --head "wbniv:fix/$b" --fill
done
```

Or open each from the browser via its "compare" link below.

## The eight PRs

| # | Branch | Fix | Tests |
|---|---|---|---|
| 0 | ✅ **MERGED [#720](https://github.com/vhelin/wla-dx/pull/720)** | `WLAVALRGIND` typo silently skipped `wlalink` Valgrind in 10 tests | 12/12 CI green; merged |
| 1 | ✅ **MERGED [#721](https://github.com/vhelin/wla-dx/pull/721)** | eZ80 FD-prefixed index loads encoded the wrong register | 12/12 CI green; merged |
| 2 | ✅ **MERGED [#722](https://github.com/vhelin/wla-dx/pull/722)** | MC68000 labels/defines `S0`–`S7` parsed as register A7 | 12/12 CI green; merged |
| 3 | 🟢 **OPEN [#724](https://github.com/vhelin/wla-dx/pull/724)** | FORCE/OVERWRITE section labels in macros resolved to section start | open; awaiting review (CI running) |
| 4 | 🟢 **OPEN [#723](https://github.com/vhelin/wla-dx/pull/723)** | `mid()` signed overflow → SIGSEGV | 12/12 CI green; awaiting review |
| 5 | 🟢 **OPEN [#725](https://github.com/vhelin/wla-dx/pull/725)** | `.REPT`/`.REPEAT` hung on an unexpected trailing token | open; awaiting review (CI running) |
| 6 | ⏸️ **not submitted** | `wlalink` duplicate-label resolution flipped to first-wins under `-c` | branch ready; behavioural — left as a question for the maintainer (in the review report) |
| 7 | ⏸️ **not submitted** | 4 `-Wmaybe-uninitialized` warnings in decode.c | branch ready; maintainer will review on his own |

---

### 0. WLAVALRGIND typo silently skips wlalink Valgrind in ten tests

- **Files:** ten `makefile`s under `tests/gb-z80/*` and `tests/z80n/instructions_test`
- **What:** the line `LD = $(WLAVALRGIND) wlalink` misspells the `WLAVALGRIND` variable that `run_tests.sh` exports, so it expanded to nothing and `wlalink` ran **without** Valgrind in these tests (the assembler `CC` line was spelled correctly). One-token fix, no source/behaviour change.
- **Verification:** all ten tests pass under Valgrind 3.25.1 with the suite's strict config (`--leak-check=full --errors-for-leak-kinds=all --error-exitcode=1`). With the fix, `wlalink` now actually runs under Valgrind — confirmed via its own `Command: wlalink …` block reporting `ERROR SUMMARY: 0 errors` and no leaks (previously its memory was never checked here). Also confirmed clean under GCC AddressSanitizer/LeakSanitizer.
- **Open:** [compare](https://github.com/vhelin/wla-dx/compare/master...wbniv:fix/valgrind-variable-typo?expand=1) · `gh pr create --repo vhelin/wla-dx --base master --head wbniv:fix/valgrind-variable-typo --fill`

### 1. eZ80 FD-prefixed index loads emit the wrong register

- **Files:** `iez80.c`, `tests/ez80/{instructions_test,all_instructions_test}/main.s`
- **Repro (fixed):** `ld ix,(iy+1)` → `FD 31 01` (was `FD 37 01` = `ld iy,(iy+1)`); `ld (iy+1),iy` → `FD 3F 01`; DD-page `ld ix,(ix+1)` unchanged `DD 37 01`.
- **Note:** the eZ80 test suite asserted the buggy bytes; the 10 FD-page IY-base `@BT` lines were corrected in the same commit.
- **Open:** [compare](https://github.com/vhelin/wla-dx/compare/master...wbniv:fix/ez80-fd-index-loads?expand=1) · `gh pr create --repo vhelin/wla-dx --base master --head wbniv:fix/ez80-fd-index-loads --fill`

### 2. MC68000 labels/definitions named S0–S7 parse as register A7

- **Files:** `decode.c` (6 register-parse sites), `tests/68000/sp_alias_test/`
- **Repro (fixed):** `S3: move.w S3,d0` → `30 39 00 00 00 03` (was `30 0f` = `move.w a7,d0`); `move.w sp,d2` still `34 0f`.
- **Open:** [compare](https://github.com/vhelin/wla-dx/compare/master...wbniv:fix/68000-s-register-alias?expand=1) · `gh pr create --repo vhelin/wla-dx --base master --head wbniv:fix/68000-s-register-alias --fill`

### 3. Section-relative labels passed to .MACRO resolve to the section start

- **Files:** `stack.c` (`_resolve_string`), `tests/65816/macro_section_label_test/`
- **Repro (fixed):** two labels at offsets 0 and 5 in a FORCE section, passed to a macro, now differ by 5 (was 0).
- **Open:** [compare](https://github.com/vhelin/wla-dx/compare/master...wbniv:fix/macro-section-label-address?expand=1) · `gh pr create --repo vhelin/wla-dx --base master --head wbniv:fix/macro-section-label-address --fill`

### 4. mid() integer overflow can crash the assembler

- **Files:** `stack.c` (`_parse_function_left_mid_right`), `tests/6502/functions_error_test/`
- **Repro (fixed):** `.db mid(1, 2147483647, "abc")` → clean error, exit 1 (was SIGSEGV, exit 139). Verified the test fails against the unpatched binary.
- **Open:** [compare](https://github.com/vhelin/wla-dx/compare/master...wbniv:fix/mid-integer-overflow?expand=1) · `gh pr create --repo vhelin/wla-dx --base master --head wbniv:fix/mid-integer-overflow --fill`

### 5. .REPT/.REPEAT hangs on an unexpected token after the count

- **Files:** `phase_1.c` (`.REPT` option loop), `tests/z80/rept_error_test/`
- **Repro (fixed):** `.rept 2 5` → clear "unexpected token" error, exit 1 (was an infinite hang). Valid `START`/`STEP` still assemble (`03 05 07`).
- **Open:** [compare](https://github.com/vhelin/wla-dx/compare/master...wbniv:fix/rept-infinite-loop?expand=1) · `gh pr create --repo vhelin/wla-dx --base master --head wbniv:fix/rept-infinite-loop --fill`

### 6. wlalink duplicate-label resolution flipped to first-wins

- **Files:** `wlalink/write.c` (`_try_put_label`), `tests/gb-z80/duplicate_labels_lastwins/`
- **Repro (fixed):** two objects export `DUP` ($11 then $22) under `-c`; the later object wins → `$22` (the unpatched binary gives `$11`). Verified both directions.
- **Open:** [compare](https://github.com/vhelin/wla-dx/compare/master...wbniv:fix/wlalink-duplicate-label-lastwins?expand=1) · `gh pr create --repo vhelin/wla-dx --base master --head wbniv:fix/wlalink-duplicate-label-lastwins --fill`

### 7. Silence -Wmaybe-uninitialized for SH-2 immediate operands

- **Files:** `decode.c` (`_sh2_parse_number`)
- **Repro (fixed):** clean rebuild emits 0 warnings (was 4: decode.c:2119/2140/2159/2174). No behavioural change.
- **Open:** [compare](https://github.com/vhelin/wla-dx/compare/master...wbniv:fix/sh2-uninitialized-warnings?expand=1) · `gh pr create --repo vhelin/wla-dx --base master --head wbniv:fix/sh2-uninitialized-warnings --fill`

---

## Notes for upstream

- AI attribution mirrors the project's own convention: an in-file `; NOTE: This test was created by Claude Fable 5.` comment in each added test file (like the existing `all_instructions_test` suites), and **no** `Co-Authored-By` commit trailer. Source-only branches (decode.c warnings, the makefile typo) add no test and therefore no AI comment, matching how the project leaves hand-edited sources uncredited.
- Every regression test for a crash/hang/wrong-byte was confirmed to **fail against the unpatched binary** (fixes 4 and 6 shown explicitly), so each test genuinely guards its bug.
- The full suite stays green on each branch: `make -C build -j && ./run_tests.sh`.
