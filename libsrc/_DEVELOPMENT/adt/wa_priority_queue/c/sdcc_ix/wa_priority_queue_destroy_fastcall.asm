
; void wa_priority_queue_destroy_fastcall(ba_priority_queue_t *q)

SECTION code_clib
SECTION code_adt_wa_priority_queue

PUBLIC _wa_priority_queue_destroy_fastcall

EXTERN asm_wa_priority_queue_destroy

defc _wa_priority_queue_destroy_fastcall = asm_wa_priority_queue_destroy
