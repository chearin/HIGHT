#pragma once
#include <stdio.h>
#include <stdint.h>

void WKSchedule(uint32_t* WK, const uint32_t* MK);
void GenSTable(uint8_t* s);
uint8_t GenDelta(const uint8_t* s);
void SKSchedule(uint32_t* SK, const uint32_t* MK);

void initialTran(uint32_t* X, const uint32_t* WK, const uint32_t* PT);
void finalTran(uint32_t* CT, const uint32_t* WK, const uint32_t* X);

void F0_2block(uint32_t* AX, const uint32_t BX);
void F1_2block(uint32_t* AX, const uint32_t BX);
void EncRound(uint32_t* AX, const uint32_t* SK, const uint32_t* BX);
void EncRound2(uint32_t* AX, const uint32_t* SK, const uint32_t* BX);

void bitMasking(uint32_t* X, uint8_t n);
void Encryption_2block(uint32_t* CT1, uint32_t* CT2, const uint32_t* WK, const uint32_t* SK, const uint32_t* PT1, const uint32_t* PT2);
