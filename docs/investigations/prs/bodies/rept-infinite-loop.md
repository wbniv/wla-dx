The `.REPT`/`.REPEAT` `START`/`STEP` option loop only broke out on end-of-line: any other token after the count was read, rolled back, and retried on the next iteration — forever. So `.REPT 2 5` (or any stray token after the count) hung the assembler, and a parse failure printed the same error in an endless loop.

**Introduced in** [`b44d8341`](https://github.com/vhelin/wla-dx/commit/b44d8341a0cb33c5981108e6ae80a2714a9b5458) ("Added START and STEP to .REPEAT/.REPT", GitHub #670), which added the option-parsing loop. Its only exit is end-of-line; anything else is rolled back and the enclosing `while (1)` retries it indefinitely:

```diff
+      q = input_number();
+      if (q == INPUT_NUMBER_EOL) {
+        g_parsed_int = counter;
+        next_line();
+        break;
+      }
+      else {
+        /* this is not yet the end */
+        roll_back_to_remembered_source_file_position();   // → loops forever on a stray token
+      }
```

After the `INDEX`/`START`/`STEP` checks, require end-of-line: a parse failure returns `FAILED`, and anything else reports a clear "unexpected token" error and returns `FAILED`. Same-line `.REPT` bodies were already non-functional in this version (`.ENDR` continuation skips to the next line), so this only turns a non-terminating hang into a diagnostic.

Adds `tests/z80/rept_error_test`, asserting `.REPT 2 5` is rejected.
