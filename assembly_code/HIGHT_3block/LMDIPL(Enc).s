# void initialTran(uint32_t* X, const uint32_t* WK, const uint32_t* PT)
.macro initialTran, WK
    lw t0, 0(\WK)
    lw t1, 4(\WK)
    lw t3, 8(\WK)
    lw t4, 12(\WK)    
    # X[0] = PT[0] + WK[0];
    add s0, s0, t0
    # X[2] = PT[2] ^ WK[1];    
    xor s2, s2, t1
    # X[4] = PT[4] + WK[2];    
    add s4, s4, t3
    # X[6] = PT[6] ^ WK[3];    
    xor s6, s6, t4
    # bit masking
    li t2, 0xff0ff0ff
    and s0, s0, t2
    and s4, s4, t2
.endm

# void finalTran(uint32_t* CT, const uint32_t* WK, const uint32_t* X)
.macro finalTran, WK
    lw t0, 16(\WK)
    lw t1, 20(\WK)
    lw t2, 24(\WK)
    lw t3, 28(\WK)
    # CT[0] = X[0] + WK[4];    
    add s1, s1, t0
    # CT[2] = X[2] ^ WK[5];    
    xor s3, s3, t1
    # CT[4] = X[4] + WK[6];    
    add s5, s5, t2
    # CT[6] = X[6] ^ WK[7];    
    xor s7, s7, t3
.endm

# void F0_3block(uint32_t* AX, const uint32_t BX)
.macro F0_3block, R, X
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
    mv \R, t3
.endm

# void F1_3block(uint32_t* AX, const uint32_t BX)
.macro F1_3block, R, X
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
    mv \R, t3
.endm

# void EncRound(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
.macro EncRound, SK
    # 1R
    lw s9, 12(\SK)
    lw s10, 0(\SK)
    lw s11, 4(\SK)
    lw a5, 8(\SK)
    # F0_3block(temp, BX[6]);
    F0_3block s8, s6
    # AX[0] = temp2[3] ^ (temp + SK[3]);    
    add s9, s8, s9
    xor s7, s7, s9
    # F1_3block(temp, BX[0]);
    F1_3block s8, s0
    # AX[2] = temp2[0] + (temp ^ SK[0]);    
    xor s10, s8, s10
    add s1, s1, s10
    # F0_3block(temp, BX[2]);
    F0_3block s8, s2
    # AX[4] = temp2[1] ^ (temp + SK[1]);    
    add s11, s8, s11
    xor s3, s3, s11
    # F1_3block(temp, BX[4]);
    F1_3block s8, s4
    # AX[6] = temp2[2] + (temp ^ SK[2]);    
    xor a5, s8, a5
    add s5, s5, a5
    # bit masking
    and s1, s1, t2
    and s3, s3, t2
    and s5, s5, t2
    and s7, s7, t2

    # 2R
    lw s9, 28(\SK)
    lw s10, 16(\SK)
    lw s11, 20(\SK)
    lw a5, 24(\SK)
    # F0_3block(temp, BX[6]);
    F0_3block s8, s5
    # AX[0] = temp2[3] ^ (temp + SK[3]);    
    add s9, s8, s9
    xor s6, s6, s9
    # F1_3block(temp, BX[0]);
    F1_3block s8, s7
    # AX[2] = temp2[0] + (temp ^ SK[0]);    
    xor s10, s8, s10
    add s0, s0, s10
    # F0_3block(temp, BX[2]);
    F0_3block s8, s1
    # AX[4] = temp2[1] ^ (temp + SK[1]);    
    add s11, s8, s11
    xor s2, s2, s11
    # F1_3block(temp, BX[4]);
    F1_3block s8, s3
    # AX[6] = temp2[2] + (temp ^ SK[2]);    
    xor a5, s8, a5
    add s4, s4, a5
    # bit masking
    and s0, s0, t2
    and s2, s2, t2
    and s4, s4, t2
    and s6, s6, t2

    # 3R
    lw s9, 44(\SK)
    lw s10, 32(\SK)
    lw s11, 36(\SK)
    lw a5, 40(\SK)
    # F0_3block(temp, BX[6]);
    F0_3block s8, s4
    # AX[0] = temp2[3] ^ (temp + SK[3]);
    add s9, s8, s9
    xor s5, s5, s9
    # F1_3block(temp, BX[0]);
    F1_3block s8, s6
    # AX[2] = temp2[0] + (temp ^ SK[0]);    
    xor s10, s8, s10
    add s7, s7, s10
    # F0_3block(temp, BX[2]);
    F0_3block s8, s0
    # AX[4] = temp2[1] ^ (temp + SK[1]);    
    add s11, s8, s11
    xor s1, s1, s11
    # F1_3block(temp, BX[4]);
    F1_3block s8, s2
    # AX[6] = temp2[2] + (temp ^ SK[2]);
    xor a5, s8, a5
    add s3, s3, a5
    # bit masking
    and s1, s1, t2
    and s3, s3, t2
    and s5, s5, t2
    and s7, s7, t2

    # 4R
    lw s9, 60(\SK)
    lw s10, 48(\SK)
    lw s11, 52(\SK)
    lw a5, 56(\SK)
    # F0_3block(temp, BX[6]);
    F0_3block s8, s3
    # AX[0] = temp2[3] ^ (temp + SK[3]);    
    add s9, s8, s9
    xor s4, s4, s9
    # F1_3block(temp, BX[0]);
    F1_3block s8, s5
    # AX[2] = temp2[0] + (temp ^ SK[0]);    
    xor s10, s8, s10
    add s6, s6, s10
    # F0_3block(temp, BX[2]);
    F0_3block s8, s7
    # AX[4] = temp2[1] ^ (temp + SK[1]);    
    add s11, s8, s11
    xor s0, s0, s11
    # F1_3block(temp, BX[4]);
    F1_3block s8, s1
    # AX[6] = temp2[2] + (temp ^ SK[2]);    
    xor a5, s8, a5
    add s2, s2, a5
    # bit masking
    and s0, s0, t2
    and s2, s2, t2
    and s4, s4, t2
    and s6, s6, t2

    # 5R
    lw s9, 76(\SK)
    lw s10, 64(\SK)
    lw s11, 68(\SK)
    lw a5, 72(\SK)
    # F0_3block(temp, BX[6]);
    F0_3block s8, s2
    # AX[0] = temp2[3] ^ (temp + SK[3]);    
    add s9, s8, s9
    xor s3, s3, s9
    # F1_3block(temp, BX[0]);
    F1_3block s8, s4
    # AX[2] = temp2[0] + (temp ^ SK[0]);    
    xor s10, s8, s10
    add s5, s5, s10
    # F0_3block(temp, BX[2]);
    F0_3block s8, s6
    # AX[4] = temp2[1] ^ (temp + SK[1]);    
    add s11, s8, s11
    xor s7, s7, s11
    # F1_3block(temp, BX[4]);
    F1_3block s8, s0
    # AX[6] = temp2[2] + (temp ^ SK[2]);    
    xor a5, s8, a5
    add s1, s1, a5
    # bit masking
    and s1, s1, t2
    and s3, s3, t2
    and s5, s5, t2
    and s7, s7, t2

    # 6R
    lw s9, 92(\SK)
    lw s10, 80(\SK)
    lw s11, 84(\SK)
    lw a5, 88(\SK)
    # F0_3block(temp, BX[6]);
    F0_3block s8, s1
    # AX[0] = temp2[3] ^ (temp + SK[3]);    
    add s9, s8, s9
    xor s2, s2, s9
    # F1_3block(temp, BX[0]);
    F1_3block s8, s3
    # AX[2] = temp2[0] + (temp ^ SK[0]);    
    xor s10, s8, s10
    add s4, s4, s10
    # F0_3block(temp, BX[2]);
    F0_3block s8, s5
    # AX[4] = temp2[1] ^ (temp + SK[1]);    
    add s11, s8, s11
    xor s6, s6, s11
    # F1_3block(temp, BX[4]);
    F1_3block s8, s7
    # AX[6] = temp2[2] + (temp ^ SK[2]);    
    xor a5, s8, a5
    add s0, s0, a5
    # bit masking
    and s0, s0, t2
    and s2, s2, t2
    and s4, s4, t2
    and s6, s6, t2

    # 7R
    lw s9, 108(\SK)
    lw s10, 96(\SK)
    lw s11, 100(\SK)
    lw a5, 104(\SK)
    # F0_3block(temp, BX[6]);
    F0_3block s8, s0
    # AX[0] = temp2[3] ^ (temp + SK[3]);    
    add s9, s8, s9
    xor s1, s1, s9
    # F1_3block(temp, BX[0]);
    F1_3block s8, s2
    # AX[2] = temp2[0] + (temp ^ SK[0]);    
    xor s10, s8, s10
    add s3, s3, s10
    # F0_3block(temp, BX[2]);
    F0_3block s8, s4
    # AX[4] = temp2[1] ^ (temp + SK[1]);    
    add s11, s8, s11
    xor s5, s5, s11
    # F1_3block(temp, BX[4]);
    F1_3block s8, s6
    # AX[6] = temp2[2] + (temp ^ SK[2]);    
    xor a5, s8, a5
    add s7, s7, a5
    # bit masking
    and s1, s1, t2
    and s3, s3, t2
    and s5, s5, t2
    and s7, s7, t2

    # 8R
    lw s9, 124(\SK)
    lw s10, 112(\SK)
    lw s11, 116(\SK)
    lw a5, 120(\SK)
    # F0_3block(temp, BX[6]);
    F0_3block s8, s7
    # AX[0] = temp2[3] ^ (temp + SK[3]);    
    add s9, s8, s9
    xor s0, s0, s9
    # F1_3block(temp, BX[0]);
    F1_3block s8, s1
    # AX[2] = temp2[0] + (temp ^ SK[0]);    
    xor s10, s8, s10
    add s2, s2, s10
    # F0_3block(temp, BX[2]);
    F0_3block s8, s3
    # AX[4] = temp2[1] ^ (temp + SK[1]);    
    add s11, s8, s11
    xor s4, s4, s11
    # F1_3block(temp, BX[4]);
    F1_3block s8, s5
    # AX[6] = temp2[2] + (temp ^ SK[2]);    
    xor a5, s8, a5
    add s6, s6, a5
    # bit masking
    and s0, s0, t2
    and s2, s2, t2
    and s4, s4, t2
    and s6, s6, t2
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
    # PT: s0-s7, temp: t0 t1, t2 t3, t4 t5, s8 s9, PT1: a5, PT2: a6, PT3: a7
    # PT[0] PT[1] PT[2] PT[3] (pipelining)
    lw t1, 0(a7)
    lw t3, 4(a7)
    lw t5, 8(a7)
    lw s9, 12(a7)
    lw t0, 0(a6)
    slli t1, t1, 12
    slli t3, t3, 12
    slli t5, t5, 12
    slli s9, s9, 12
    lw t2, 4(a6)
    add t1, t1, t0
    lw t4, 8(a6)
    lw s8, 12(a6)
    lw s0, 0(a5)
    add t3, t3, t2
    add t5, t5, t4    
    add s9, s9, s8
    slli t1, t1, 12
    lw s1, 4(a5)
    lw s2, 8(a5)
    lw s3, 12(a5)
    slli t3, t3, 12
    slli t5, t5, 12
    slli s9, s9, 12
    add s0, t1, s0
    add s1, t3, s1
    add s2, t5, s2
    add s3, s9, s3
    # PT[4] PT[5] PT[6] PT[7] (pipelining)
    lw t1, 16(a7)
    lw t3, 20(a7)
    lw t5, 24(a7)
    lw s9, 28(a7)
    lw t0, 16(a6)
    slli t1, t1, 12
    slli t3, t3, 12
    slli t5, t5, 12
    slli s9, s9, 12
    lw t2, 20(a6)
    add t1, t1, t0
    lw t4, 24(a6)
    lw s8, 28(a6)
    lw s4, 16(a5)
    add t3, t3, t2
    add t5, t5, t4    
    add s9, s9, s8
    slli t1, t1, 12
    lw s5, 20(a5)
    lw s6, 24(a5)
    lw s7, 28(a5)
    slli t3, t3, 12
    slli t5, t5, 12
    slli s9, s9, 12
    add s4, t1, s4
    add s5, t3, s5
    add s6, t5, s6
    add s7, s9, s7

    # initial
    initialTran a3
    # 1-32round
    li t0, 0
    li t1, 4
ROUND_LOOP:
    beq t0, t1, ROUND_END
    EncRound a4
    addi t0, t0, 1
    addi a4, a4, 128
    j ROUND_LOOP
ROUND_END:
    # final
    finalTran a3

    # unpacking (CT3|0000|CT2|0000|CT1)
    # CT: s0-s7, bitmask: t2, temp: t3, CT1: a0, CT2: a1, CT3: a2
    li t2, 0xff
    # CT[0]
    and t3, s0, t2
    sw t3, 28(a0)
    srli s0, s0, 12
    and t3, s0, t2
    sw t3, 28(a1)
    srli s0, s0, 12
    sw s0, 28(a2)
    # CT[1]
    and t3, s1, t2
    sw t3, 0(a0)
    srli s1, s1, 12
    and t3, s1, t2
    sw t3, 0(a1)
    srli s1, s1, 12
    sw s1, 0(a2)
    # CT[2]
    and t3, s2, t2
    sw t3, 4(a0)
    srli s2, s2, 12
    and t3, s2, t2
    sw t3, 4(a1)
    srli s2, s2, 12
    sw s2, 4(a2)
    # CT[3]
    and t3, s3, t2
    sw t3, 8(a0)
    srli s3, s3, 12
    and t3, s3, t2
    sw t3, 8(a1)
    srli s3, s3, 12
    sw s3, 8(a2)
    # CT[4]
    and t3, s4, t2
    sw t3, 12(a0)
    srli s4, s4, 12
    and t3, s4, t2
    sw t3, 12(a1)
    srli s4, s4, 12
    sw s4, 12(a2)
    # CT[5]
    and t3, s5, t2
    sw t3, 16(a0)
    srli s5, s5, 12
    and t3, s5, t2
    sw t3, 16(a1)
    srli s5, s5, 12
    sw s5, 16(a2)
    # CT[6]
    and t3, s6, t2
    sw t3, 20(a0)
    srli s6, s6, 12
    and t3, s6, t2
    sw t3, 20(a1)
    srli s6, s6, 12
    sw s6, 20(a2)
    # CT[7]
    and t3, s7, t2
    sw t3, 24(a0)
    srli s7, s7, 12
    and t3, s7, t2
    sw t3, 24(a1)
    srli s7, s7, 12
    sw s7, 24(a2)

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
