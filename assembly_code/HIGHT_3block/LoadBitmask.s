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
    li t2, 0xff0ff0ff
    and s0, s0, t2
    and s4, s4, t2
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
.endm

# void F0_3block(uint32_t* AX, const uint32_t BX)
.macro F0_3block, X
    # X<<<1
    # temp1[0] = BX << 1;
    mv t3, \X
    slli t3, t3, 1
    # temp2[0] = BX >> 4;
    mv t4, \X
    srli t4, t4, 4
    # temp2[0] &= 0xff0ff0ff;
    and t4, t4, t2
    # temp2[0] = temp2[0] >> 3;
    srli t4, t4, 3
    # temp1[0] ^= temp2[0];
    xor t3, t3, t4
    # temp1[0] &= 0xff0ff0ff;
    and t3, t3, t2

    # X<<<2
    # temp1[1] = BX << 2;
    mv t4, \X
    slli t4, t4, 2
    # temp2[1] = BX >> 4;
    mv t5, \X
    srli t5, t5, 4
    # temp2[1] &= 0xff0ff0ff;
    and t5, t5, t2
    # temp2[1] = temp2[1] >> 2;
    srli t5, t5, 2
    # temp1[1] ^= temp2[1];
    xor t4, t4, t5
    # temp1[1] &= 0xff0ff0ff;
    and t4, t4, t2

    # X<<<7
    # temp1[2] = BX << 4;
    mv t5, \X
    slli t5, t5, 4
    # temp1[2] &= 0xff0ff0ff;
    and t5, t5, t2
    # temp1[2] = temp1[2] << 3;
    slli t5, t5, 3
    # temp2[2] = BX >> 1;
    mv a6, \X
    srli a6, a6, 1
    # temp1[2] ^= temp2[2];
    xor t5, t5, a6
    # temp1[2] &= 0xff0ff0ff;
    and t5, t5, t2

    # *AX = temp1[0] ^ temp1[1] ^ temp1[2];
    xor t3, t3, t4
    xor t3, t3, t5
    mv \X, t3
.endm

# void F1_3block(uint32_t* AX, const uint32_t BX)
.macro F1_3block, X
    # X<<<3
    # temp1[0] = BX << 3;
    mv t3, \X
    slli t3, t3, 3
    # temp2[0] = BX >> 4;
    mv t4, \X
    srli t4, t4, 4
    # temp2[0] &= 0xff0ff0ff;
    and t4, t4, t2
    # temp2[0] = temp2[0] >> 1;
    srli t4, t4, 1
    # temp1[0] ^= temp2[0];
    xor t3, t3, t4
    # temp1[0] &= 0xff0ff0ff;
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
    # temp1[1] &= 0xff0ff0ff;
    and t4, t4, t2

    # X<<<6
    # temp1[2] = BX << 4;
    mv t5, \X
    slli t5, t5, 4
    # temp1[2] &= 0xff0ff0ff;
    and t5, t5, t2
    # temp1[2] = temp1[2] << 2;
    slli t5, t5, 2
    # temp2[2] = BX >> 2;
    mv a6, \X
    srli a6, a6, 2
    # temp1[2] ^= temp2[2];
    xor t5, t5, a6
    # temp1[2] &= 0xff0ff0ff;
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
    # F0_3block(temp, BX[6]);
    F0_3block s6
    # F1_3block(temp + 1, BX[0]);
    F1_3block s0
    # F0_3block(temp + 2, BX[2]);
    F0_3block s2
    # F1_3block(temp + 3, BX[4]);
    F1_3block s4
    # AX[0] = temp2[3] ^ (temp[0] + SK[3]);
    lw a6, 12(\SK)
    add a6, s6, a6
    xor t3, s11, a6
    # AX[2] = temp2[0] + (temp[1] ^ SK[0]);
    lw a6, 0(\SK)
    xor a6, s0, a6
    add t4, s8, a6
    mv s0, t3
    # AX[4] = temp2[1] ^ (temp[2] + SK[1]);
    lw a6, 4(\SK)
    add a6, s2, a6
    xor t3, s9, a6
    mv s2, t4
    # AX[6] = temp2[2] + (temp[3] ^ SK[2]);
    lw a6, 8(\SK)
    xor a6, s4, a6
    add s6, s10, a6
    mv s4, t3
    # bit masking
    and s0, s0, t2
    and s2, s2, t2
    and s4, s4, t2
    and s6, s6, t2
.endm

# void EncRound2(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
.macro EncRound2 SK
    mv s8, s0
    mv s9, s2
    mv s10, s4
    mv s11, s6
    # F1_3block(temp, BX[0]);
    F1_3block s0
    # F0_3block(temp + 1, BX[2]);
    F0_3block s2
    # F1_3block(temp + 2, BX[4]);
    F1_3block s4
    # F0_3block(temp + 3, BX[6]);
    F0_3block s6
    # AX[1] = BX[1] + (temp[0] ^ SK[0]);
    lw a6, 0(\SK)
    xor a6, s0, a6
    add s1, s1, a6
    # AX[3] = BX[3] ^ (temp[1] + SK[1]);
    lw a6, 4(\SK)
    add a6, s2, a6
    xor s3, s3, a6
    # AX[5] = BX[5] + (temp[2] ^ SK[2]);
    lw a6, 8(\SK)
    xor a6, s4, a6
    add s5, s5, a6
    # AX[7] = BX[7] ^ (temp[3] + SK[3]);
    lw a6, 12(\SK)
    add a6, s6, a6
    xor s7, s7, a6
    # AX[0] = BX[0];
    # AX[2] = BX[2];
    # AX[4] = BX[4];
    # AX[6] = BX[6];
    mv s0, s8
    mv s2, s9
    mv s4, s10
    mv s6, s11
    # bit masking
    and s1, s1, t2
    and s3, s3, t2
    and s5, s5, t2
    and s7, s7, t2
.endm

.text
.global Encryption_3block
.type Encryption_3block, @function
# void Encryption_3block(uint32_t* CT1, uint32_t* CT2, uint32_t* CT3, const uint32_t* WK, const uint32_t* SK, const uint32_t* PT1, const uint32_t* PT2, const uint32_t* PT3)
Encryption_3block:
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

    # packing (PT3|0000|PT2|0000|PT1)
    # PT: s0-s7, temp: t3 t4, PT1: a5, PT2: a6, PT3: a7
    # PT[0]
    lw s0, 0(a5)
    lw t3, 0(a6)
    lw t4, 0(a7)
    slli t4, t4, 12
    add t4, t4, t3
    slli t4, t4, 12
    add s0, t4, s0
    # PT[1]
    lw s1, 4(a5)
    lw t3, 4(a6)
    lw t4, 4(a7)
    slli t4, t4, 12
    add t4, t4, t3
    slli t4, t4, 12
    add s1, t4, s1
    # PT[2]
    lw s2, 8(a5)
    lw t3, 8(a6)
    lw t4, 8(a7)
    slli t4, t4, 12
    add t4, t4, t3
    slli t4, t4, 12
    add s2, t4, s2
    # PT[3]
    lw s3, 12(a5)
    lw t3, 12(a6)
    lw t4, 12(a7)
    slli t4, t4, 12
    add t4, t4, t3
    slli t4, t4, 12
    add s3, t4, s3
    # PT[4]
    lw s4, 16(a5)
    lw t3, 16(a6)
    lw t4, 16(a7)
    slli t4, t4, 12
    add t4, t4, t3
    slli t4, t4, 12
    add s4, t4, s4
    # PT[5]
    lw s5, 20(a5)
    lw t3, 20(a6)
    lw t4, 20(a7)
    slli t4, t4, 12
    add t4, t4, t3
    slli t4, t4, 12
    add s5, t4, s5
    # PT[6]
    lw s6, 24(a5)
    lw t3, 24(a6)
    lw t4, 24(a7)
    slli t4, t4, 12
    add t4, t4, t3
    slli t4, t4, 12
    add s6, t4, s6
    # PT[7]
    lw s7, 28(a5)
    lw t3, 28(a6)
    lw t4, 28(a7)
    slli t4, t4, 12
    add t4, t4, t3
    slli t4, t4, 12
    add s7, t4, s7

    # initial
    initialTran a3
    # 1-31round
    li t0, 1
    li t1, 32
ROUND_LOOP:
    beq t0, t1, ROUND_END
    EncRound a4
    addi t0, t0, 1
    addi a4, a4, 16
    j ROUND_LOOP
ROUND_END:
    # 32round
    EncRound2 a4
    # final
    finalTran a3

    # unpacking (CT3|0000|CT2|0000|CT1)
    # CT: s0-s7, bitmask: t2, temp: t3, CT1: a0, CT2: a1, CT3: a2
    li t2, 0xff
    # CT[0]
    and t3, s0, t2
    sw t3, 0(a0)
    srli s0, s0, 12
    and t3, s0, t2
    sw t3, 0(a1)
    srli s0, s0, 12
    sw s0, 0(a2)
    # CT[1]
    and t3, s1, t2
    sw t3, 4(a0)
    srli s1, s1, 12
    and t3, s1, t2
    sw t3, 4(a1)
    srli s1, s1, 12
    sw s1, 4(a2)
    # CT[2]
    and t3, s2, t2
    sw t3, 8(a0)
    srli s2, s2, 12
    and t3, s2, t2
    sw t3, 8(a1)
    srli s2, s2, 12
    sw s2, 8(a2)
    # CT[3]
    and t3, s3, t2
    sw t3, 12(a0)
    srli s3, s3, 12
    and t3, s3, t2
    sw t3, 12(a1)
    srli s3, s3, 12
    sw s3, 12(a2)
    # CT[4]
    and t3, s4, t2
    sw t3, 16(a0)
    srli s4, s4, 12
    and t3, s4, t2
    sw t3, 16(a1)
    srli s4, s4, 12
    sw s4, 16(a2)
    # CT[5]
    and t3, s5, t2
    sw t3, 20(a0)
    srli s5, s5, 12
    and t3, s5, t2
    sw t3, 20(a1)
    srli s5, s5, 12
    sw s5, 20(a2)
    # CT[6]
    and t3, s6, t2
    sw t3, 24(a0)
    srli s6, s6, 12
    and t3, s6, t2
    sw t3, 24(a1)
    srli s6, s6, 12
    sw s6, 24(a2)
    # CT[7]
    and t3, s7, t2
    sw t3, 28(a0)
    srli s7, s7, 12
    and t3, s7, t2
    sw t3, 28(a1)
    srli s7, s7, 12
    sw s7, 28(a2)

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
