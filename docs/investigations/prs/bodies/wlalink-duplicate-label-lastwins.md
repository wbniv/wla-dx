When duplicate labels/definitions are allowed (`-c`, or `-C` with equal values), `_try_put_label` returned early without inserting the duplicate, so the **first** definition won every later lookup. Before the duplicate-check split, this function always called `hashmap_put`, which overwrites the stored pointer on a key match — so the **last** definition won. The early return was an unintended side effect of the split and silently changed linked output across the version bump, with no diagnostic.

Drop the early return so an allowed duplicate falls through to `hashmap_put` and overwrites, restoring last-wins. The check-only pass (`duplicate_check == YES`) is unchanged.

Adds `tests/gb-z80/duplicate_labels_lastwins`: two objects export `DUP` with different values under `-c`, and the later object wins (`$22`). Verified in both directions — the test gives `$11` against the unpatched binary.
