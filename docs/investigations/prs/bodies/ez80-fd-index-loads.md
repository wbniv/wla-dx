On the eZ80, the second opcode byte under an `FD` prefix selects IX at `0x31`/`0x3E` and IY at `0x37`/`0x3F` — the inverse of the ED/DD pages. Four table entries carried the DD-page mapping onto the FD page, so these register-to-register index loads/stores silently assembled to the wrong instruction:

| Source | Was | Actually decodes as | Correct |
|---|---|---|---|
| `ld ix,(iy+d)` | `FD 37 d` | `ld iy,(iy+d)` | `FD 31 d` |
| `ld iy,(iy+d)` | `FD 31 d` | `ld ix,(iy+d)` | `FD 37 d` |
| `ld (iy+d),ix` | `FD 3F d` | `ld (iy+d),iy` | `FD 3E d` |
| `ld (iy+d),iy` | `FD 3E d` | `ld (iy+d),ix` | `FD 3F d` |

Swap the four encodings to match the FD page. Cross-checked against CEmu and binutils; the DD-page entries (`LD IX,(IXs)` = `DD 37`, `LD IY,(IXs)` = `DD 31`, `LD (IXs),IX` = `DD 3F`, `LD (IXs),IY` = `DD 3E`) are already correct and untouched.

The eZ80 regression tests asserted the buggy bytes, so they certified the defect rather than catching it. The ten affected `@BT` expectations in `instructions_test` and `all_instructions_test` (FD-page IY-base forms only) are corrected in the same commit.
