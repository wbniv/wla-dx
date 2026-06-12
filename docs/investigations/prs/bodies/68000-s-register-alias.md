The new `SP` alias for address register A7 widened the operand parser's register condition to accept a leading `S`, but the digit branch was not gated to A/D. So a token like `S3` satisfied the `'0'..'7'` digit test and was then forced to A7 — meaning any label or definition named `S0`..`S7` used as an operand silently assembled as A7. For example:

```
move.w S3,d0   ->  30 0f      (i.e. move.w a7,d0)
```

instead of an absolute reference to `S3`.

Gate the digit branch with `c != 'S'` at all six MC68000 register-parse sites, so only the exact token `SP` maps to A7; `S3` now falls through to normal label/number parsing.

Adds `tests/68000/sp_alias_test`, asserting that a label `S3` and a definition `S6` resolve to their address/value while `SP` and `A7` still emit the A7 form.
