# WLA-DX v10.7 — Seven correctness fixes as atomic PR branches

## Context

The v10.6→v10.7 review ([docs/investigations/2026-06-12-v10.6-to-v10.7-code-review.md](../../SRC/wla-dx/docs/investigations/2026-06-12-v10.6-to-v10.7-code-review.md)) found four 🔴 critical wrong-codegen bugs, two 🟠 crash/hang/silent-output bugs, and four `-Wmaybe-uninitialized` build warnings — all introduced or surfaced in v10.7. Each was reproduced on freshly built binaries. This plan turns the seven fixes into **seven atomic branches**, each with the source fix plus a regression test, pushed to a personal fork of `vhelin/wla-dx`. **No upstream PRs are opened** — each branch ships with a PR-description doc so the user opens PRs manually.

All fixes are independent (different files/subsystems), so each branch is cut from clean `master`.

Repo facts: `origin` = [vhelin/wla-dx](https://github.com/vhelin/wla-dx.git) (upstream, no fork yet); authed as `wbniv` (`repo` scope). Tests run via `./run_tests.sh` (iterates `tests/*/*/`, runs `make`, then `byte_tester testsfile`/inline `@BT`). Negative/error tests use the `megadrive_error_test` pattern (a `check:` target that expects a nonzero `wla` exit and greps the log). All 182 tests currently pass and **must stay green** — note that fix #1 requires correcting tests that currently assert the buggy bytes.

---

## The seven fixes

### 1. eZ80 FD-page index loads emit the wrong register — branch `fix/ez80-fd-index-loads`

`iez80.c`: under an `FD` prefix the second opcode byte selects IX at `0x31`/`0x3E` and IY at `0x37`/`0x3F` — the inverse of the ED/DD pages. Four entries have the DD-page mapping. **Swap pairwise** (DD-page anchors at lines 549/578/579/583 confirm the targets; cross-checked vs CEmu and binutils):

| Line | Entry | Now | Fix |
|---|---|---|---|
| 550 | `LD IX,(IYs)` | `0x37fd` | `0x31fd` |
| 584 | `LD IY,(IYs)` | `0x31fd` | `0x37fd` |
| 612 | `LD (IYs),IX` | `0x3ffd` | `0x3efd` |
| 613 | `LD (IYs),IY` | `0x3efd` | `0x3ffd` |

**The test suite enshrines the bug** — correct these 10 `@BT` expectations in the same commit or `run_tests.sh` breaks:
- `tests/ez80/instructions_test/main.s`: `:120` `FD 37 05`→`FD 31 05`, `:123` `FD 3F F8`→`FD 3E F8`
- `tests/ez80/all_instructions_test/main.s`: `:626`/`:2192` `FD 37 74`→`FD 31 74`; `:660`/`:2211` `FD 31 6E`→`FD 37 6E`; `:688`/`:2225` `FD 3F 1A`→`FD 3E 1A`; `:689`/`:2226` `FD 3E 27`→`FD 3F 27`. (DD-page lines 625/654/655/659/2191/2206/2207/2210 are correct — leave them.)

Verify: `ld ix,(iy+1)` now assembles to `FD 31 01` (was `FD 37 01`); `ld ix,(ix+1)` stays `DD 37 01`.

### 2. 68000 labels `S0`–`S7` parse as register A7 — branch `fix/68000-s-register-alias`

`decode.c`: the new `SP` alias widened the register-parse condition but didn't gate the *digit* disjunct. Six sites (**969, 1035, 1100, 1295, 1347, 1373**) share the pattern `(code[i] >= '0' && code[i] <= '7') || (c == 'S' && toupper(code[i]) == 'P')`. At each, gate the first disjunct so `S`+digit no longer matches an address register:

```c
if ((c != 'S' && code[i] >= '0' && code[i] <= '7') || (c == 'S' && toupper((int)code[i]) == 'P')) {
```

(`c != 'S'` is provably equivalent to "A or D" given each site's outer `if`, and makes all six edits identical.)

Regression test: new `tests/68000/sp_alias_test/` — define labels `S0:`/`S3:`, use as operands (`move.w S3,d0`) and assert the **absolute-address** encoding (`30 38 …`, not `30 0f` = A7); also assert `move.w sp,d0` still emits the A7 form. Exact bytes captured from the build during execution.

### 3. Section-relative labels passed to macros resolve to the section start — branch `fix/macro-section-label-address`

`stack.c:4062`, in the FORCE/OVERWRITE branch of `_resolve_string`:

```c
-      s->value = g_slots[section->slot].address + section->address;
+      s->value = g_slots[section->slot].address + dSI->address;
```

Confirmed: `dSI->address` is the label's absolute in-slot address (set from `s_dsp_add`, `stack.c:5975`), `dSI->slot == section->slot` for in-section labels, no double-count — parallels the correct outside-section branch at `:4045`.

Regression test: extend `tests/65816/macro_test_2/main.s` — a label at non-zero offset inside a FORCE section, passed to a macro and emitted, must yield `ORG+offset` (e.g. `Second` at ORG+1), not the section base.

### 4. `mid()` integer overflow → SIGSEGV — branch `fix/mid-integer-overflow`

`stack.c:1478`, `_parse_function_left_mid_right`:

```c
-  if (start + length > string_length) {
+  if (length > string_length - start) {
```

Overflow-safe: at this point `0 ≤ start ≤ string_length` (checked `:1474`) and `length ≥ 0` (`:1468`), so `string_length - start ∈ [0, string_length]`. The loop then writes ≤ `MAX_NAME_LENGTH` bytes into `si->string`.

Tests: (a) positive `mid()` assertion appended to `tests/6502/functions_test/main.s`; (b) negative error test `tests/6502/functions_error_test/` with `.db mid(1, 2147483647, "abc")`, expecting nonzero exit + an error in the log (megadrive_error_test pattern) — proves no segfault.

### 5. `.REPT`/`.REPEAT` hangs on an unexpected trailing token — branch `fix/rept-infinite-loop`

`phase_1.c` ~10922–10934: the START/STEP option loop only exits on `INPUT_NUMBER_EOL`; any other token is rolled back and re-tested forever (`.REPT 2 5` hangs). Replace the EOL test (drop the now-dead `_remember_current_source_file_position()` at `:10923`):

```c
q = input_number();
if (q == INPUT_NUMBER_EOL) {
  g_parsed_int = counter;
  next_line();
  break;
}
else if (q == FAILED)
  return FAILED;                       /* input_number already reported it */
else {
  print_error(ERROR_DIR, ".%s got an unexpected token. Expected INDEX, START, STEP or end of line.\n", c);
  return FAILED;
}
```

Strictly safe: it only converts a non-terminating hang into a clear error; same-line `.REPT` bodies are already non-functional in v10.7 (`_directive_endr_continue` skips to the next newline), and every `tests/z80/rept_test` case uses keyword options.

Regression test: negative test `tests/z80/rept_error_test/` with `.rept 2 5` expecting nonzero exit + grep.

### 6. wlalink silently flipped duplicate-label resolution to first-wins — branch `fix/wlalink-duplicate-label-lastwins`

`wlalink/write.c`, `_try_put_label`, `duplicate_check == NO` branch: when a duplicate exists and dups are allowed, the code returns early without inserting (first-wins). v10.6 always called `hashmap_put`, which overwrites (last-wins) — confirmed via `git show v10.6` and `hashmap.c` (`e->data = value` on key match). The early return was an accidental side effect of the `-c`/`-C` split (commit `e473ece7`). Delete the early return so control reaches `hashmap_put` at `:2342`:

```c
       return FAILED;
     }
-
-      /* don't insert duplicates into the hashmap */
-      return SUCCEEDED;
   }

   if ((err = hashmap_put(map, l->name, l)) != MAP_OK) {
```

(Leave the `duplicate_check == YES` check-only branch untouched.)

Regression test: a duplicate-label test linked with `-c` (allow differing values) where the same label is defined twice with **different** addresses across banks; assert the **last** definition wins via bytes. The existing `tests/gb-z80/duplicate_labels` uses `-C` with equal values and can't distinguish, so add a sibling `duplicate_labels_lastwins/` (or extend with a `-c` variant).

### 7. Four `-Wmaybe-uninitialized` warnings in decode.c — branch `fix/sh2-uninitialized-warnings`

`decode.c:1581`, `_sh2_parse_number` writes `*value` only for `SUCCEEDED`/`STACK`; the four SH-2 `IMM8*` call sites (2119/2140/2159/2174) pass an uninitialized `value` that `_sh2_emit_low8` reads only when set — a false positive GCC can't prove. Make the out-param always defined:

```c
 static int _sh2_parse_number(int *index, int *value, int *result_type, char *label) {
   int old_index, result;
+
+  *value = 0;
```

No behavior change; silences all four warnings.

---

## Critical files

- `iez80.c` (fix 1) + `tests/ez80/{instructions_test,all_instructions_test}/main.s`
- `decode.c` (fixes 2 and 7) — six S-register sites + `_sh2_parse_number`
- `stack.c` (fixes 3 and 4) — `_resolve_string:4062`, `_parse_function_left_mid_right:1478`
- `phase_1.c` (fix 5) — `.REPT` option loop ~10931
- `wlalink/write.c` (fix 6) — `_try_put_label:2338`
- New/edited tests under `tests/68000/`, `tests/65816/`, `tests/6502/`, `tests/z80/`, `tests/gb-z80/`

## Delivery

1. Create the fork [wbniv/wla-dx](https://github.com/wbniv/wla-dx) via `gh repo fork vhelin/wla-dx --clone=false --remote=false` (touches no existing remotes), then add it as a git remote named `fork` pointing at that fork's `.git` URL.
2. Per fix: `git checkout master` → `git checkout -b <branch>` → apply edit(s) + test → **build + verify** (below) → `git commit` → `git push -u fork <branch>`.
3. Write one PR-description doc per branch under `docs/investigations/prs/<branch>.md` (title, summary, evidence/repro, test) plus the `gh pr create` command and the GitHub compare URL printed on push. Open no PRs.
4. Commit messages follow repo style (imperative subject; reference the GitHub issue where known — e.g. #718 relates to the eZ80 `.L` area but these are distinct) and end with the `Co-Authored-By: Claude` trailer per house rule (user can strip for upstream).

## Verification (per branch, before commit)

Build once up front (`cmake -B build -DCMAKE_BUILD_TYPE=Release && make -C build -j`); after each fix rebuild the affected target and run the full suite:

```
make -C build -j && ./run_tests.sh        # expect: OK (≥182 tests), all green
```

Plus the bug-specific repro (assemble a tiny program with the built binaries):

1. eZ80: `ld ix,(iy+1)` → `FD 31 01`; `ld iy,(iy+1)` → `FD 37 01`; `ld ix,(ix+1)` unchanged `DD 37 01`. New `@BT` lines pass.
2. 68000: `S3: move.w S3,d0` → absolute encoding (`30 38 …`), not `30 0f`; `move.w sp,d0` still A7.
3. stack: FORCE section at ORG `$10`, `First`(off 0)/`Second`(off 1) via macro `.PRINTV` → `16`/`17` (was `16`/`16`).
4. mid: `.db mid(1,2147483647,"abc")` → clean error + nonzero exit (was SIGSEGV/139); positive `mid()` bytes correct.
5. .REPT: `.REPT 2 5` → error + nonzero exit within ~1 s (was hang/timeout 124); valid `.rept` START/STEP still assemble.
6. wlalink: same label at two addresses under `-c` → linked bytes reference the **last** definition.
7. warnings: `make -C build` shows **0** warnings (was 4); suite unchanged.

Each branch's new/edited test encodes its repro, so a green `run_tests.sh` is the durable proof.
