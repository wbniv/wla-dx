# TODO — wla-dx

## In progress

(none)

## Done

- [x] **MERGED ([#720](https://github.com/vhelin/wla-dx/pull/720))** — `WLAVALRGIND`→`WLAVALGRIND` typo in 10 makefiles; wlalink now runs under Valgrind; 12/12 CI green; merged by maintainer.
- [x] v10.7 correctness fixes — 7 atomic branches pushed to fork `wbniv/wla-dx`, each fix+regression test, suite green; PR index in [docs/investigations/prs/README.md](docs/investigations/prs/README.md). Plan: [docs/plans/2026-06-12-…](docs/plans/2026-06-12-wla-dx-v10-7-seven-correctness-fixes-as-atomic-pr.md). Review: [docs/investigations/2026-06-12-…](docs/investigations/2026-06-12-v10.6-to-v10.7-code-review.md).
- [x] **MERGED ([#721](https://github.com/vhelin/wla-dx/pull/721))** — eZ80 FD-page index loads emitted wrong register (`fix/ez80-fd-index-loads`); corrected 10 enshrined `@BT` tests.
- [x] **MERGED ([#722](https://github.com/vhelin/wla-dx/pull/722))** — MC68000 labels `S0`–`S7` parsed as A7 (`fix/68000-s-register-alias`); +sp_alias_test.
- [x] **OPEN ([#723](https://github.com/vhelin/wla-dx/pull/723))** — `mid()` integer overflow segfault (`fix/mid-integer-overflow`); +functions_error_test; awaiting review.
- [x] **OPEN ([#724](https://github.com/vhelin/wla-dx/pull/724))** — FORCE/OVERWRITE section labels in macros resolved to section start (`fix/macro-section-label-address`); +macro_section_label_test; cites breaking commit 44ca5c12; awaiting review.
- [x] **OPEN ([#725](https://github.com/vhelin/wla-dx/pull/725))** — `.REPT`/`.REPEAT` hang on an unexpected token (`fix/rept-infinite-loop`); +rept_error_test; cites breaking commit b44d8341; awaiting review.
- [x] **Not submitted by design** — `fix/sh2-uninitialized-warnings` (cosmetic; maintainer reviews himself) and `fix/wlalink-duplicate-label-lastwins` (behavioural; left as a question for the maintainer, who has the review report). Branches remain on the fork.
- [x] FORCE/OVERWRITE section labels in macros resolved to section start (`fix/macro-section-label-address`); +macro_section_label_test.
- [x] `mid()` signed overflow → SIGSEGV (`fix/mid-integer-overflow`); +functions_error_test (verified vs unpatched).
- [x] `.REPT 2 5` infinite hang (`fix/rept-infinite-loop`); +rept_error_test.
- [x] wlalink duplicate-label first-wins regression under `-c` (`fix/wlalink-duplicate-label-lastwins`); +duplicate_labels_lastwins (verified both ways).
- [x] 4 decode.c `-Wmaybe-uninitialized` warnings (`fix/sh2-uninitialized-warnings`); clean build, 0 warnings.
