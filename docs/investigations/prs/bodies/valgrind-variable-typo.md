Ten test makefiles set `LD = $(WLAVALRGIND) wlalink`, but the variable is spelled `WLAVALGRIND` everywhere else, and `run_tests.sh` only ever exports `WLAVALGRIND`. The misspelled `$(WLAVALRGIND)` expanded to nothing, so `wlalink` ran **without** Valgrind in these ten tests — even though the assembler on the `CC` line right above it did not. The result was that linker memory checking was silently skipped here. This corrects the spelling in all ten makefiles; there is no source or behaviour change.

**Affected makefiles**

- `tests/gb-z80/`: `ai_generated_tests`, `continue_test`, `delta_test`, `duplicate_labels`, `gbheader_test`, `instructions_test`, `labels_test`, `listfile_test`, `macro_parser_test`
- `tests/z80n/instructions_test`

**Verification (Valgrind 3.25.1)** — ran all ten under the suite's strict config (`--leak-check=full --errors-for-leak-kinds=all --error-exitcode=1`). All ten pass, and `wlalink` now actually runs under Valgrind. For example in `duplicate_labels`:

```
==…== Command: wlalink -i -v -C -s linkfile linked.gb
==…== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

Zero errors and no leaks. Before this fix that `wlalink` Valgrind run never happened, so the linker's memory was never checked in these tests.
