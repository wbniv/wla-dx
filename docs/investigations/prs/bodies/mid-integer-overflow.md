`mid()`'s out-of-range check computed `start + length > string_length`. For a large length — e.g. `mid(1, 2147483647, "abc")` — `start + length` overflowed to a negative value, the check passed, and the following copy loop wrote ~2 GB into the 256-byte stack item. A segfault driven purely by assembler source input.

Compare as `length > string_length - start` instead. At that point `0 <= start <= string_length` and `length >= 0` are already guaranteed, so `string_length - start` is a non-negative in-range value and the subtraction cannot overflow. `left()`/`right()` share the same check.

Adds `tests/6502/functions_error_test`, asserting the oversized `mid()` is rejected with a clean error. The test greps the log for the range message, which a crash would never print — so it genuinely fails against the unpatched (crashing) binary.
