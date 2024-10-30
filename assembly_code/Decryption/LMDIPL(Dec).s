# void Dec_initialTran(uint32_t* X, const uint32_t* WK, const uint32_t* PT)
.macro Dec_initialTran, WK
    li a7, 0x00f00f00
    lw t0, 16(\WK)
    lw t1, 20(\WK)
    lw t3, 24(\WK)
    lw t4, 28(\WK)    
    # X[0] = CT[0] | 0x00f00f00;
    # X[0] = X[0] - WK[4];
    or s0, s0, a7
    sub s0, s0, t0
    # X[2] = CT[2] ^ WK[5]; 
    xor s2, s2, t1
    # X[4] = CT[4] | 0x00f00f00;
    # X[4] = X[4] - WK[6];
    or s4, s4, a7   
    sub s4, s4, t3
    # X[6] = CT[6] ^ WK[7];
    xor s6, s6, t4
    # bit masking
    li t2, 0xff0ff0ff
    and s0, s0, t2
    and s4, s4, t2
.endm

# void Dec_finalTran(uint32_t* CT, const uint32_t* WK, const uint32_t* X)
.macro Dec_finalTran, WK
    lw t0, 0(\WK)
    lw t1, 4(\WK)
    lw t2, 8(\WK)
    lw t3, 12(\WK)
    # PT[0] = X[0] | 0x00f00f00;
    # PT[0] = PT[0] - WK[0];
    or s7, s7, a7
    sub s7, s7, t0
    # PT[2] = X[2] ^ WK[1];  
    xor s1, s1, t1
    # PT[4] = X[4] | 0x00f00f00;
    # PT[4] = PT[4] - WK[2];
    or s3, s3, a7
    sub s3, s3, t2
    # PT[6] = X[6] ^ WK[3];    
    xor s5, s5, t3
.endm

# void Dec_F0_3block(uint32_t* AX, const uint32_t BX)
.macro Dec_F0_3block, R, X
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

# void Dec_F1_3block(uint32_t* AX, const uint32_t BX)
.macro Dec_F1_3block, R, X
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

# void DecRound(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
.macro DecRound, SK
    # 1R
    lw s9, 0(\SK)
    lw s10, 4(\SK)
    lw s11, 8(\SK)
    lw a5, 12(\SK)
    # F0_3block(temp + 3, BX[6]);
    Dec_F0_3block s8, s6
    # AX[6] = temp2[3] ^ (temp[3] + SK[0]);
    add s9, s8, s9
    xor s7, s7, s9
    # F1_3block(temp, BX[0]);
    Dec_F1_3block s8, s0
    # AX[0] = temp2[0] - (temp[0] ^ SK[3]);
    xor a5, s8, a5
    or s1, s1, a7    
    sub s1, s1, a5
    # F0_3block(temp + 1, BX[2]);
    Dec_F0_3block s8, s2
    # AX[2] = temp2[1] ^ (temp[1] + SK[2]);    
    add s11, s8, s11
    xor s3, s3, s11
    # F1_3block(temp + 2, BX[4]);
    Dec_F1_3block s8, s4
    # AX[4] = temp2[2] - (temp[2] ^ SK[1]);    
    xor s10, s8, s10
    or s5, s5, a7 
    sub s5, s5, s10
    # bit masking
    and s1, s1, t2
    and s3, s3, t2
    and s5, s5, t2
    and s7, s7, t2

    # 2R
    lw s9, 16(\SK)
    lw s10, 20(\SK)
    lw s11, 24(\SK)
    lw a5, 28(\SK)
    # F0_3block(temp + 3, BX[6]);
    Dec_F0_3block s8, s7
    # AX[6] = temp2[3] ^ (temp[3] + SK[0]);   
    add s9, s8, s9
    xor s0, s0, s9
    # F1_3block(temp, BX[0]);
    Dec_F1_3block s8, s1
    # AX[0] = temp2[0] - (temp[0] ^ SK[3]);
    xor a5, s8, a5
    or s2, s2, a7
    sub s2, s2, a5
    # F0_3block(temp + 1, BX[2]);
    Dec_F0_3block s8, s3
    # AX[2] = temp2[1] ^ (temp[1] + SK[2]);    
    add s11, s8, s11
    xor s4, s4, s11
    # F1_3block(temp + 2, BX[4]);
    Dec_F1_3block s8, s5
    # AX[4] = temp2[2] - (temp[2] ^ SK[1]); 
    xor s10, s8, s10
    or s6, s6, a7 
    sub s6, s6, s10
    # bit masking
    and s0, s0, t2
    and s2, s2, t2
    and s4, s4, t2
    and s6, s6, t2

    # 3R
    lw s9, 32(\SK)
    lw s10, 36(\SK)
    lw s11, 40(\SK)
    lw a5, 44(\SK)
    # F0_3block(temp + 3, BX[6]);
    Dec_F0_3block s8, s0
    # AX[6] = temp2[3] ^ (temp[3] + SK[0]);   
    add s9, s8, s9
    xor s1, s1, s9
    # F1_3block(temp, BX[0]);
    Dec_F1_3block s8, s2
    # AX[0] = temp2[0] - (temp[0] ^ SK[3]);
    xor a5, s8, a5
    or s3, s3, a7
    sub s3, s3, a5
    # F0_3block(temp + 1, BX[2]);
    Dec_F0_3block s8, s4
    # AX[2] = temp2[1] ^ (temp[1] + SK[2]);    
    add s11, s8, s11
    xor s5, s5, s11
    # F1_3block(temp + 2, BX[4]);
    Dec_F1_3block s8, s6
    # AX[4] = temp2[2] - (temp[2] ^ SK[1]); 
    xor s10, s8, s10
    or s7, s7, a7
    sub s7, s7, s10
    # bit masking
    and s1, s1, t2
    and s3, s3, t2
    and s5, s5, t2
    and s7, s7, t2

    # 4R
    lw s9, 48(\SK)
    lw s10, 52(\SK)
    lw s11, 56(\SK)
    lw a5, 60(\SK)
    # F0_3block(temp + 3, BX[6]);
    Dec_F0_3block s8, s1
    # AX[6] = temp2[3] ^ (temp[3] + SK[0]);   
    add s9, s8, s9
    xor s2, s2, s9
    # F1_3block(temp, BX[0]);
    Dec_F1_3block s8, s3
    # AX[0] = temp2[0] - (temp[0] ^ SK[3]);
    xor a5, s8, a5
    or s4, s4, a7
    sub s4, s4, a5
    # F0_3block(temp + 1, BX[2]);
    Dec_F0_3block s8, s5
    # AX[2] = temp2[1] ^ (temp[1] + SK[2]);    
    add s11, s8, s11
    xor s6, s6, s11
    # F1_3block(temp + 2, BX[4]);
    Dec_F1_3block s8, s7
    # AX[4] = temp2[2] - (temp[2] ^ SK[1]); 
    xor s10, s8, s10
    or s0, s0, a7
    sub s0, s0, s10
    # bit masking
    and s0, s0, t2
    and s2, s2, t2
    and s4, s4, t2
    and s6, s6, t2

    # 5R
    lw s9, 64(\SK)
    lw s10, 68(\SK)
    lw s11, 72(\SK)
    lw a5, 76(\SK)
    # F0_3block(temp + 3, BX[6]);
    Dec_F0_3block s8, s2
    # AX[6] = temp2[3] ^ (temp[3] + SK[0]);   
    add s9, s8, s9
    xor s3, s3, s9
    # F1_3block(temp, BX[0]);
    Dec_F1_3block s8, s4
    # AX[0] = temp2[0] - (temp[0] ^ SK[3]);
    xor a5, s8, a5
    or s5, s5, a7
    sub s5, s5, a5
    # F0_3block(temp + 1, BX[2]);
    Dec_F0_3block s8, s6
    # AX[2] = temp2[1] ^ (temp[1] + SK[2]);    
    add s11, s8, s11
    xor s7, s7, s11
    # F1_3block(temp + 2, BX[4]);
    Dec_F1_3block s8, s0
    # AX[4] = temp2[2] - (temp[2] ^ SK[1]); 
    xor s10, s8, s10
    or s1, s1, a7
    sub s1, s1, s10
    # bit masking
    and s1, s1, t2
    and s3, s3, t2
    and s5, s5, t2
    and s7, s7, t2

    # 6R
    lw s9, 80(\SK)
    lw s10, 84(\SK)
    lw s11, 88(\SK)
    lw a5, 92(\SK)
    # F0_3block(temp + 3, BX[6]);
    Dec_F0_3block s8, s3
    # AX[6] = temp2[3] ^ (temp[3] + SK[0]);   
    add s9, s8, s9
    xor s4, s4, s9
    # F1_3block(temp, BX[0]);
    Dec_F1_3block s8, s5
    # AX[0] = temp2[0] - (temp[0] ^ SK[3]);
    xor a5, s8, a5
    or s6, s6, a7
    sub s6, s6, a5
    # F0_3block(temp + 1, BX[2]);
    Dec_F0_3block s8, s7
    # AX[2] = temp2[1] ^ (temp[1] + SK[2]);    
    add s11, s8, s11
    xor s0, s0, s11
    # F1_3block(temp + 2, BX[4]);
    Dec_F1_3block s8, s1
    # AX[4] = temp2[2] - (temp[2] ^ SK[1]); 
    xor s10, s8, s10
    or s2, s2, a7
    sub s2, s2, s10
    # bit masking
    and s0, s0, t2
    and s2, s2, t2
    and s4, s4, t2
    and s6, s6, t2

    # 7R
    lw s9, 96(\SK)
    lw s10, 100(\SK)
    lw s11, 104(\SK)
    lw a5, 108(\SK)
    # F0_3block(temp + 3, BX[6]);
    Dec_F0_3block s8, s4
    # AX[6] = temp2[3] ^ (temp[3] + SK[0]);   
    add s9, s8, s9
    xor s5, s5, s9
    # F1_3block(temp, BX[0]);
    Dec_F1_3block s8, s6
    # AX[0] = temp2[0] - (temp[0] ^ SK[3]);
    xor a5, s8, a5
    or s7, s7, a7
    sub s7, s7, a5
    # F0_3block(temp + 1, BX[2]);
    Dec_F0_3block s8, s0
    # AX[2] = temp2[1] ^ (temp[1] + SK[2]);    
    add s11, s8, s11
    xor s1, s1, s11
    # F1_3block(temp + 2, BX[4]);
    Dec_F1_3block s8, s2
    # AX[4] = temp2[2] - (temp[2] ^ SK[1]); 
    xor s10, s8, s10
    or s3, s3, a7
    sub s3, s3, s10
    # bit masking
    and s1, s1, t2
    and s3, s3, t2
    and s5, s5, t2
    and s7, s7, t2

    # 8R
    lw s9, 112(\SK)
    lw s10, 116(\SK)
    lw s11, 120(\SK)
    lw a5, 124(\SK)
    # F0_3block(temp + 3, BX[6]);
    Dec_F0_3block s8, s5
    # AX[6] = temp2[3] ^ (temp[3] + SK[0]);   
    add s9, s8, s9
    xor s6, s6, s9
    # F1_3block(temp, BX[0]);
    Dec_F1_3block s8, s7
    # AX[0] = temp2[0] - (temp[0] ^ SK[3]);
    xor a5, s8, a5
    or s0, s0, a7
    sub s0, s0, a5
    # F0_3block(temp + 1, BX[2]);
    Dec_F0_3block s8, s1
    # AX[2] = temp2[1] ^ (temp[1] + SK[2]);    
    add s11, s8, s11
    xor s2, s2, s11
    # F1_3block(temp + 2, BX[4]);
    Dec_F1_3block s8, s3
    # AX[4] = temp2[2] - (temp[2] ^ SK[1]); 
    xor s10, s8, s10
    or s4, s4, a7
    sub s4, s4, s10
    # bit masking
    and s0, s0, t2
    and s2, s2, t2
    and s4, s4, t2
    and s6, s6, t2
.endm

.text
.global Decryption_3block
.type Decryption_3block, @function
# void Decryption_3block(uint32_t* CT1, uint32_t* CT2, uint32_t* CT3, const uint32_t* WK, const uint32_t* SK, const uint32_t* PT1, const uint32_t* PT2, const uint32_t* PT3)
Decryption_3block:
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

    # packing (CT3|0000|CT2|0000|CT1)
    # CT: s0-s7, temp: t0 t1, t2 t3, t4 t5, s8 s9, CT1: a5, CT2: a6, CT3: a7
    # CT[0] CT[1] CT[2] CT[3] (pipelining)
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
    # CT[4] CT[5] CT[6] CT[7] (pipelining)
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
    Dec_initialTran a3
    # 1-32round
    li t0, 0
    li t1, 4
DROUND_LOOP:
    beq t0, t1, DROUND_END
    DecRound a4
    addi t0, t0, 1
    addi a4, a4, 128
    j DROUND_LOOP
DROUND_END:
    # final
    Dec_finalTran a3

    # unpacking (PT3|0000|PT2|0000|PT1)
    # PT: s0-s7, bitmask: t2, temp: t3, PT1: a0, PT2: a1, PT3: a2
    li t2, 0xff
    # PT[0]
    and t3, s0, t2
    sw t3, 4(a0)
    srli s0, s0, 12
    and t3, s0, t2
    sw t3, 4(a1)
    srli s0, s0, 12
    sw s0, 4(a2)
    # PT[1]
    and t3, s1, t2
    sw t3, 8(a0)
    srli s1, s1, 12
    and t3, s1, t2
    sw t3, 8(a1)
    srli s1, s1, 12
    sw s1, 8(a2)
    # PT[2]
    and t3, s2, t2
    sw t3, 12(a0)
    srli s2, s2, 12
    and t3, s2, t2
    sw t3, 12(a1)
    srli s2, s2, 12
    sw s2, 12(a2)
    # PT[3]
    and t3, s3, t2
    sw t3, 16(a0)
    srli s3, s3, 12
    and t3, s3, t2
    sw t3, 16(a1)
    srli s3, s3, 12
    sw s3, 16(a2)
    # PT[4]
    and t3, s4, t2
    sw t3, 20(a0)
    srli s4, s4, 12
    and t3, s4, t2
    sw t3, 20(a1)
    srli s4, s4, 12
    sw s4, 20(a2)
    # PT[5]
    and t3, s5, t2
    sw t3, 24(a0)
    srli s5, s5, 12
    and t3, s5, t2
    sw t3, 24(a1)
    srli s5, s5, 12
    sw s5, 24(a2)
    # PT[6]
    and t3, s6, t2
    sw t3, 28(a0)
    srli s6, s6, 12
    and t3, s6, t2
    sw t3, 28(a1)
    srli s6, s6, 12
    sw s6, 28(a2)
    # PT[7]
    and t3, s7, t2
    sw t3, 0(a0)
    srli s7, s7, 12
    and t3, s7, t2
    sw t3, 0(a1)
    srli s7, s7, 12
    sw s7, 0(a2)

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
