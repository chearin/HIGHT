# void Dec_initialTran(uint32_t* X, const uint32_t* WK, const uint32_t* PT)
.macro Dec_initialTran, WK
    li t2, 0xff00ff00
    # X[0] = CT[0] | 0xff00ff00;
    # X[0] = X[0] - WK[4];
    lw t0, 16(\WK)
    or s0, s0, t2
    sub s0, s0, t0
    # X[2] = CT[2] ^ WK[5];
    lw t0, 20(\WK)
    xor s2, s2, t0
    # X[4] = CT[4] | 0xff00ff00;
    # X[4] = X[4] - WK[6];
    lw t0, 24(\WK)
    or s4, s4, t2
    sub s4, s4, t0
    # X[6] = CT[6] ^ WK[7];
    lw t0, 28(\WK)
    xor s6, s6, t0
    # bit masking
    li t1, 0x00ff00ff
    and s0, s0, t1
    and s4, s4, t1
.endm

# void Dec_finalTran(uint32_t* CT, const uint32_t* WK, const uint32_t* X)
.macro Dec_finalTran, WK
    li t2, 0xff00ff00
    # PT[0] = X[0] | 0xff00ff00;
    # PT[0] = PT[0] - WK[0];
    lw t0, 0(\WK)
    or s0, s0, t2
    sub s0, s0, t0
    # PT[2] = X[2] ^ WK[1];
    lw t0, 4(\WK)
    xor s2, s2, t0
    # PT[4] = X[4] | 0xff00ff00;
    # PT[4] = PT[4] - WK[2];
    lw t0, 8(\WK)
    or s4, s4, t2
    sub s4, s4, t0
    # PT[6] = X[6] ^ WK[3];
    lw t0, 12(\WK)
    xor s6, s6, t0
.endm

# void Dec_F0_2block(uint32_t* AX, const uint32_t BX)
.macro Dec_F0_2block, X
    li t2, 0x00ff00ff
    # X<<<1
    # temp1[0] = BX << 1;
    mv t3, \X
    slli t3, t3, 1
    # temp2[0] = BX >> 7;
    mv t4, \X
    srli t4, t4, 7
    # temp1[0] ^= temp2[0];
    xor t3, t3, t4
    # temp1[0] &= 0x00ff00ff;
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
    # temp1[1] &= 0x00ff00ff;
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
    # temp1[2] &= 0x00ff00ff;
    and t5, t5, t2

    # *AX = temp1[0] ^ temp1[1] ^ temp1[2];
    xor t3, t3, t4
    xor t3, t3, t5
    mv \X, t3
.endm

# void Dec_F1_2block(uint32_t* AX, const uint32_t BX)
.macro Dec_F1_2block, X
    li t2, 0x00ff00ff
    # X<<<3
    # temp1[0] = BX << 3;
    mv t3, \X
    slli t3, t3, 3
    # temp2[0] = BX >> 5;
    mv t4, \X
    srli t4, t4, 5
    # temp1[0] ^= temp2[0];
    xor t3, t3, t4
    # temp1[0] &= 0x00ff00ff;
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
    # temp1[1] &= 0x00ff00ff;
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
    # temp1[2] &= 0x00ff00ff;
    and t5, t5, t2

    # *AX = temp1[0] ^ temp1[1] ^ temp1[2];
    xor t3, t3, t4
    xor t3, t3, t5
    mv \X, t3
.endm

# void DecRound(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
.macro DecRound, SK
    # uint32_t temp2[4] = { BX[1], BX[3], BX[5], BX[7] };
    mv s8, s1
    mv s9, s3
    mv s10, s5
    mv s11, s7
    # AX[1] = BX[0];
    mv s1, s2
    # AX[3] = BX[2];
    mv s3, s4
    # AX[5] = BX[4];
    mv s5, s6
    # AX[7] = BX[6];    
    mv s7, s0
    # F1_2block(temp, BX[0]);
    Dec_F1_2block s0
    # F0_2block(temp + 1, BX[2]);
    Dec_F0_2block s2
    # F1_2block(temp + 2, BX[4]);
    Dec_F1_2block s4
    # F0_2block(temp + 3, BX[6]);
    Dec_F0_2block s6
    # temp2[0] |= 0xff00ff00;
    # temp2[2] |= 0xff00ff00;
    li t5, 0xff00ff00
    or s8, s8, t5
    or s10, s10, t5
    # AX[0] = temp2[0] - (temp[0] ^ SK[3]);
    lw t2, 12(\SK)
    xor t2, s0, t2
    sub s0, s8, t2
    # AX[2] = temp2[1] ^ (temp[1] + SK[2]);
    lw t2, 8(\SK)
    add t2, s2, t2
    xor s2, s9, t2    
    # AX[4] = temp2[2] - (temp[2] ^ SK[1]);
    lw t2, 4(\SK)
    xor t2, s4, t2
    sub s4, s10, t2
    # AX[6] = temp2[3] ^ (temp[3] + SK[0]);
    lw t2, 0(\SK)
    add t2, s6, t2
    xor s6, s11, t2
    # bit masking
    li t5, 0x00ff00ff
    and s0, s0, t5
    and s2, s2, t5
    and s4, s4, t5
    and s6, s6, t5
.endm

# void DecRound2(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
.macro DecRound2 SK
    mv s8, s0
    mv s9, s2
    mv s10, s4
    mv s11, s6
    # F1_2block(temp, BX[0]);
    Dec_F1_2block s0
    # F0_2block(temp + 1, BX[2]);
    Dec_F0_2block s2
    # F1_2block(temp + 2, BX[4]);
    Dec_F1_2block s4
    # F0_2block(temp + 3, BX[6]);
    Dec_F0_2block s6
    # temp2[0] |= 0xff00ff00;
    # temp2[2] |= 0xff00ff00;
    li t5, 0xff00ff00
    or s1, s1, t5
    or s5, s5, t5
    # AX[1] = temp2[0] - (temp[0] ^ SK[3]);
    lw t2, 12(\SK)
    xor t2, s0, t2
    sub s1, s1, t2
    # AX[3] = temp2[1] ^ (temp[1] + SK[2]);
    lw t2, 8(\SK)
    add t2, s2, t2
    xor s3, s3, t2
    # AX[5] = temp2[2] - (temp[2] ^ SK[1]);
    lw t2, 4(\SK)
    xor t2, s4, t2
    sub s5, s5, t2
    # AX[7] = temp2[3] ^ (temp[3] + SK[0]);
    lw t2, 0(\SK)
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
    li t5, 0x00ff00ff
    and s1, s1, t5
    and s3, s3, t5
    and s5, s5, t5
    and s7, s7, t5
.endm

.text
.global Decryption_2block
.type Decryption_2block, @function
# void Decryption_2block(uint32_t* PT1, uint32_t* PT2, const uint32_t* WK, const uint32_t* DSK, const uint32_t* CT1, const uint32_t* CT2)
Decryption_2block:
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

    # packing (00000000|CT2|00000000|CT1)
    # CT: s0-s7, temp: t3, CT1: a4, CT2: a5
    # CT[0]
    lw s0, 0(a4)
    lw t3, 0(a5)
    slli t3, t3, 16
    add s0, t3, s0
    # CT[1]
    lw s1, 4(a4)
    lw t3, 4(a5)
    slli t3, t3, 16
    add s1, t3, s1
    # CT[2]
    lw s2, 8(a4)
    lw t3, 8(a5)
    slli t3, t3, 16
    add s2, t3, s2
    # CT[3]
    lw s3, 12(a4)
    lw t3, 12(a5)
    slli t3, t3, 16
    add s3, t3, s3
    # CT[4]
    lw s4, 16(a4)
    lw t3, 16(a5)
    slli t3, t3, 16
    add s4, t3, s4
    # CT[5]
    lw s5, 20(a4)
    lw t3, 20(a5)
    slli t3, t3, 16
    add s5, t3, s5
    # CT[6]
    lw s6, 24(a4)
    lw t3, 24(a5)
    slli t3, t3, 16
    add s6, t3, s6
    # CT[7]
    lw s7, 28(a4)
    lw t3, 28(a5)
    slli t3, t3, 16
    add s7, t3, s7

    # initial
    Dec_initialTran a2
    # 1-31round
    li t0, 1
    li t1, 32
DROUND_LOOP:
    beq t0, t1, DROUND_END
    DecRound a3
    addi t0, t0, 1
    addi a3, a3, 16
    j DROUND_LOOP
DROUND_END:
    # 32round
    DecRound2 a3
    # final
    Dec_finalTran a2

    # unpacking (00000000|PT2|00000000|PT1)
    # PT: s0-s7, bitmask: t2, temp: t3, PT1: a0, PT2: a1
    li t2, 0xff
    # PT[0]
    and t3, s0, t2
    sw t3, 0(a0)
    srli s0, s0, 16
    and t3, s0, t2
    sw t3, 0(a1)
    # PT[1]
    and t3, s1, t2
    sw t3, 4(a0)
    srli s1, s1, 16
    and t3, s1, t2
    sw t3, 4(a1)
    # PT[2]
    and t3, s2, t2
    sw t3, 8(a0)
    srli s2, s2, 16
    and t3, s2, t2
    sw t3, 8(a1)
    # PT[3]
    and t3, s3, t2
    sw t3, 12(a0)
    srli s3, s3, 16
    and t3, s3, t2
    sw t3, 12(a1)
    # PT[4]
    and t3, s4, t2
    sw t3, 16(a0)
    srli s4, s4, 16
    and t3, s4, t2
    sw t3, 16(a1)
    # PT[5]
    and t3, s5, t2
    sw t3, 20(a0)
    srli s5, s5, 16
    and t3, s5, t2
    sw t3, 20(a1)
    # PT[6]
    and t3, s6, t2
    sw t3, 24(a0)
    srli s6, s6, 16
    and t3, s6, t2
    sw t3, 24(a1)
    # PT[7]
    and t3, s7, t2
    sw t3, 28(a0)
    srli s7, s7, 16
    and t3, s7, t2
    sw t3, 28(a1)

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
