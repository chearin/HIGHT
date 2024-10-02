#pragma once
#include <stdio.h>
#include <stdint.h>

void GenSTable(uint8_t* s);
uint8_t GenDelta(const uint8_t* s);
void SKSchedule(uint8_t* SK, const uint8_t* MK);

void initialTran(uint8_t* X, const uint8_t* WK, const uint8_t* PT);
void finalTran(uint8_t* CT, const uint8_t* WK, const uint8_t* X);

void Lrotation(uint8_t* AX, const uint8_t BX, const uint8_t n);
void F0(uint8_t* AX, const uint8_t BX);
void F1(uint8_t* AX, const uint8_t BX);
void EncRound(uint8_t* AX, const uint8_t* SK, const uint8_t* BX);
void EncRound2(uint8_t* AX, const uint8_t* SK, const uint8_t* BX);

void Encryption(uint8_t* CT, const uint8_t* MK, const uint8_t* PT);