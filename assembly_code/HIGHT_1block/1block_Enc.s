# void initialTran(uint32_t* X, const uint32_t* WK, const uint32_t* PT)
.macro initialTran, WK
    # X[0] = PT[0] + WK[0];
    lw t0, 0(\WK)
    add s0, s0, t0
    # X[2] = PT[2] ^ WK[1];
    lw t0, 4(\WK)
    xor s2, s2, t0
    # X[4] = PT[4] + WK[2];
    lw t0, 8(\WK)
    add s4, s4, t0
    # X[6] = PT[6] ^ WK[3];
    lw t0, 12(\WK)
    xor s6, s6, t0
    # bit masking
    li t1, 0x000000ff
    and s0, s0, t1
    and s4, s4, t1
.endm

# void finalTran(uint32_t* CT, const uint32_t* WK, const uint32_t* X)
.macro finalTran, WK
    # CT[0] = X[0] + WK[4];
    lw t0, 16(\WK)
    add s0, s0, t0
    # CT[2] = X[2] ^ WK[5];
    lw t0, 20(\WK)
    xor s2, s2, t0
    # CT[4] = X[4] + WK[6];
    lw t0, 24(\WK)
    add s4, s4, t0
    # CT[6] = X[6] ^ WK[7];
    lw t0, 28(\WK)
    xor s6, s6, t0
    # bit masking
    li t1, 0x000000ff
    and s0, s0, t1
    and s4, s4, t1
.endm

# void F0_1block(uint32_t* AX, const uint32_t BX)
.macro F0_1block, X
    li t2, 0x000000ff
    # X<<<1
    # temp1[0] = BX << 1;
    mv t3, \X
    slli t3, t3, 1
    # temp2[0] = BX >> 7;
    mv t4, \X
    srli t4, t4, 7
    # temp1[0] ^= temp2[0];
    xor t3, t3, t4
    # temp1[0] &= 0x000000ff;
    and t3, t3, t2

    # X<<<2
    # temp1[1] = BX << 2;
    mv t4, \X
    slli t4, t4, 2
    # temp2[1] = BX >> 6;
    mv t5, \X
    srli t5, t5, 6
    # temp1[1] ^= temp2[1];
    xor t4, t4, t5
    # temp1[1] &= 0x000000ff;
    and t4, t4, t2

    # X<<<7
    # temp1[2] = BX << 7;
    mv t5, \X
    slli t5, t5, 7
    # temp2[2] = BX >> 1;
    mv a6, \X
    srli a6, a6, 1
    # temp1[2] ^= temp2[2];
    xor t5, t5, a6
    # temp1[2] &= 0x000000ff;
    and t5, t5, t2

    # *AX = temp1[0] ^ temp1[1] ^ temp1[2];
    xor t3, t3, t4
    xor t3, t3, t5
    mv \X, t3
.endm

# void F1_1block(uint32_t* AX, const uint32_t BX)
.macro F1_1block, X
    li t2, 0x000000ff
    # X<<<3
    # temp1[0] = BX << 3;
    mv t3, \X
    slli t3, t3, 3
    # temp2[0] = BX >> 5;
    mv t4, \X
    srli t4, t4, 5
    # temp1[0] ^= temp2[0];
    xor t3, t3, t4
    # temp1[0] &= 0x000000ff;
    and t3, t3, t2

    # X<<<4
    # temp1[1] = BX << 4;
    mv t4, \X
    slli t4, t4, 4
    # temp2[1] = BX >> 4;
    mv t5, \X
    srli t5, t5, 4
    # temp1[1] ^= temp2[1];
    xor t4, t4, t5
    # temp1[1] &= 0x000000ff;
    and t4, t4, t2

    # X<<<6
    # temp1[2] = BX << 6;
    mv t5, \X
    slli t5, t5, 6
    # temp2[2] = BX >> 2;
    mv a6, \X
    srli a6, a6, 2
    # temp1[2] ^= temp2[2];
    xor t5, t5, a6
    # temp1[2] &= 0x000000ff;
    and t5, t5, t2

    # *AX = temp1[0] ^ temp1[1] ^ temp1[2];
    xor t3, t3, t4
    xor t3, t3, t5
    mv \X, t3
.endm

# void EncRound(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
.macro EncRound, SK
    # uint32_t temp2[4] = { BX[1], BX[3], BX[5], BX[7] };
    mv s8, s1
    mv s9, s3
    mv s10, s5
    mv s11, s7
    # AX[1] = BX[0];
    mv s1, s0
    # AX[3] = BX[2];
    mv s3, s2
    # AX[5] = BX[4];
    mv s5, s4
    # AX[7] = BX[6];    
    mv s7, s6
    # F0_1block(temp, BX[6]);
    F0_1block s6
    # F1_1block(temp + 1, BX[0]);
    F1_1block s0
    # F0_1block(temp + 2, BX[2]);
    F0_1block s2
    # F1_1block(temp + 3, BX[4]);
    F1_1block s4
    # AX[0] = temp2[3] ^ (temp[0] + SK[3]);
    lw t2, 12(\SK)
    add t2, s6, t2
    xor t3, s11, t2
    # AX[2] = temp2[0] + (temp[1] ^ SK[0]);
    lw t2, 0(\SK)
    xor t2, s0, t2
    add t4, s8, t2
    mv s0, t3
    # AX[4] = temp2[1] ^ (temp[2] + SK[1]);
    lw t2, 4(\SK)
    add t2, s2, t2
    xor t3, s9, t2
    mv s2, t4
    # AX[6] = temp2[2] + (temp[3] ^ SK[2]);
    lw t2, 8(\SK)
    xor t2, s4, t2
    add s6, s10, t2
    mv s4, t3
    # bit masking
    li t5, 0x000000ff
    and s0, s0, t5
    and s2, s2, t5
    and s4, s4, t5
    and s6, s6, t5
.endm

# void EncRound2(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
.macro EncRound2 SK
    mv s8, s0
    mv s9, s2
    mv s10, s4
    mv s11, s6
    # F1_1block(temp, BX[0]);
    F1_1block s0
    # F0_1block(temp + 1, BX[2]);
    F0_1block s2
    # F1_1block(temp + 2, BX[4]);
    F1_1block s4
    # F0_1block(temp + 3, BX[6]);
    F0_1block s6
    # AX[1] = BX[1] + (temp[0] ^ SK[0]);
    lw t2, 0(\SK)
    xor t2, s0, t2
    add s1, s1, t2
    # AX[3] = BX[3] ^ (temp[1] + SK[1]);
    lw t2, 4(\SK)
    add t2, s2, t2
    xor s3, s3, t2
    # AX[5] = BX[5] + (temp[2] ^ SK[2]);
    lw t2, 8(\SK)
    xor t2, s4, t2
    add s5, s5, t2
    # AX[7] = BX[7] ^ (temp[3] + SK[3]);
    lw t2, 12(\SK)
    add t2, s6, t2
    xor s7, s7, t2
    # AX[0] = BX[0];
    # AX[2] = BX[2];
    # AX[4] = BX[4];
    # AX[6] = BX[6];
    mv s0, s8
    mv s2, s9
    mv s4, s10
    mv s6, s11
    # bit masking
    li t5, 0x000000ff
    and s1, s1, t5
    and s3, s3, t5
    and s5, s5, t5
    and s7, s7, t5
.endm

.text
.global Encryption_1block
.type Encryption_1block, @function
# void Encryption_1block(uint32_t* CT1, const uint32_t* WK, const uint32_t* SK, const uint32_t* PT1)
Encryption_1block:
    addi sp, sp, -48
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)

    # packing (00000000|00000000|00000000|PT1)
    # PT: s0-s7, PT1: a3
    # PT[0]
    lw s0, 0(a3)
    # PT[1]
    lw s1, 4(a3)
    # PT[2]
    lw s2, 8(a3)
    # PT[3]
    lw s3, 12(a3)
    # PT[4]
    lw s4, 16(a3)
    # PT[5]
    lw s5, 20(a3)
    # PT[6]
    lw s6, 24(a3)
    # PT[7]
    lw s7, 28(a3)

    # initial
    initialTran a1
    # 1-31round
    li t0, 1
    li t1, 32
ROUND_LOOP:
    beq t0, t1, ROUND_END
    EncRound a2
    addi t0, t0, 1
    addi a2, a2, 16
    j ROUND_LOOP
ROUND_END:
    # 32round
    EncRound2 a2
    # final
    finalTran a1

    # unpacking (00000000|CT2|00000000|CT1)
    # CT: s0-s7, CT1: a0
    # CT[0]
    sw s0, 0(a0)
    # CT[1]
    sw s1, 4(a0)
    # CT[2]
    sw s2, 8(a0)
    # CT[3]
    sw s3, 12(a0)
    # CT[4]
    sw s4, 16(a0)
    # CT[5]
    sw s5, 20(a0)
    # CT[6]
    sw s6, 24(a0)
    # CT[7]
    sw s7, 28(a0)

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    addi sp, sp, 48

    ret
