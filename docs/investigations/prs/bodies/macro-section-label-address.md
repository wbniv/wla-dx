When a label defined inside a FORCE/OVERWRITE `.SECTION` is passed to a `.MACRO` and used in an assembly-time calculation, `_resolve_string` computed its value as the section's start address (`g_slots[...].address + section->address`) instead of the label's own address. Every label in the section therefore collapsed to the same value, so e.g. the difference of two such labels evaluated to 0.

**Introduced in** [`44ca5c12`](https://github.com/vhelin/wla-dx/commit/44ca5c127f8a16f060aaf2d3c14899c532bc969d) ("`.BASE`/`BASE` affects now labels when replaced with their address in `.MACRO` arguments", GitHub #649), which added both resolution branches at once — and only the in-section one used the wrong address:

```diff
+  /* a label outside .SECTIONs */
+  s->value = g_slots[dSI->slot].address + dSI->address;            // the label  (correct)
...
+  /* a label inside a FORCE/OVERWRITE .SECTION */
+  s->value = g_slots[section->slot].address + section->address;    // the section start  (bug)
```

The outside-section branch already used the label's own `dSI->address`; the FORCE/OVERWRITE branch used `section->address`. This fix makes the second match the first.

Use the label's address from the data-stream item (`dSI->address`, the absolute in-slot address) — mirroring the outside-section branch, which already uses `g_slots[dSI->slot].address + dSI->address`.

Adds `tests/65816/macro_section_label_test`, asserting that two labels at different offsets in a FORCE section, passed to a macro, yield their true distance rather than 0.
