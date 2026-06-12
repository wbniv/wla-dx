; NOTE: This test was created by Claude Fable 5.
.include "mem.s"

.BANK 0 SLOT 0
.ORG 0

; @BT linked.gb

; Regression test for duplicate-label resolution under -c (duplicates allowed
; even when their values differ). The LAST definition the linker sees must
; win, as it did before the duplicate-check split. a.s exports DUP = $11 and
; b.s exports DUP = $22; b.o is linked last, so DUP must resolve to $22.
        .db "LW>"              ; @BT TEST-01 LW START
        .db DUP                ; @BT 22
        .db "<LW"              ; @BT END
