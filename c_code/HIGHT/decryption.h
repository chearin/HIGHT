#pragma once
#include <stdio.h>
#include <stdint.h>
#include "encryption.h"

void Dec_initialTran(uint8_t* X, const uint8_t* WK, const uint8_t* PT);
void Dec_finalTran(uint8_t* CT, const uint8_t* WK, const uint8_t* X);

void DecRound(uint8_t* AX, const uint8_t* SK, const uint8_t* BX);
void DecRound2(uint8_t* AX, const uint8_t* SK, const uint8_t* BX);

void Decryption(uint8_t* CT, const uint8_t* MK, const uint8_t* PT);