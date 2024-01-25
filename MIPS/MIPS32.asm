li $s0, 0x1234ABCD
# 上条伪指令被解释为:
lui $s0, 0x1234
ori $s0, 0xABCD

#  2 -  3: $v0 - $v1
#  4 -  7: $a0 - $a3
#  8 - 15: $t0 - $t7
# 16 - 23: $s0 - $s7
# 24 - 25: $t8 - $t9
# 26 - 27: $k0 - $k1
#      28: $gp
#      29: $sp
#      30: $fp
#      31: $ra

# 运算
add/sub dest, src1, src2     # R
addi dest, src, imm          # I
and/or/nor dest, src1, src2  # R
ori dest, src, imm           # I
sll/srl dest, src, shift     # R
# 数据传送
lw/sw reg, imm(reg)          # I
lui reg, imm                 # I
# 决策指令
beq/bne src1, src2, .LABEL   # I
slt dest, src1, src2         # R
j .LABEL                     #
jr dest                      # R
# 伪指令
blt/bgt/ble/bge src1, src2, .LABEL
move/li dest, src

# 32 位 MIPS 指令格式:
# +------+-----+-----+-----+-----+------+
# |  op  | rs  | rt  | rd  |shamt|funct |
# +------+-----+-----+-----+-----+------+
#
# R 型指令:
# +------+-----+-----+-----+-----+------+
# |000000| rs  | rt  | rd  |00000|funct |
# +------+-----+-----+-----+-----+------+
# +------+-----+-----+-----+-----+------+
# |000000| rs  |00000| rd  |shamt|funct |
# +------+-----+-----+-----+-----+------+
#
# I 型指令:
# +------+-----+-----+------------------+
# |  op  | rs  | rd  |    offset/imm    |
# +------+-----+-----+------------------+
# +------+-----+-----+------------------+
# |  op  | rs  | rt  |      label       |
# +------+-----+-----+------------------+


# Local Variables:
# coding: utf-8-unix
# eval: (unless (char-equal asm-comment-char ?#)
#         ;; 逆天 ‘asm-mode’ 只能这么手动实现 file local variable.
#         (add-hook 'asm-mode-set-comment-hook
#                   (letrec ((MIPS-asm-comment-char-setter
#                             (lambda ()
#                               (remove-hook 'asm-mode-set-comment-hook
#                                            MIPS-asm-comment-char-setter)
#                               (setq-local asm-comment-char ?#))))
#                     MIPS-asm-comment-char-setter))
#         (normal-mode))
# End:
