; unsigned char esx_disk_filemap(uint8_t handle,struct esx_filemap *fmap)

SECTION code_esxdos

PUBLIC esx_disk_filemap_callee

EXTERN asm_esx_disk_filemap

esx_disk_filemap_callee:

   pop af
   pop hl
   pop de
   push af
   
   ld a,e
   jp asm_esx_disk_filemap
