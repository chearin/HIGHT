#pragma once
#include <stdio.h>
#include <stdint.h>
#include "encryption.h"

void Dec_initialTran(uint32_t* X, const uint32_t* WK, const uint32_t* PT);
void Dec_finalTran(uint32_t* CT, const uint32_t* WK, const uint32_t* X);

void DecRound(uint32_t* AX, const uint32_t* SK, const uint32_t* BX);
void DecRound2(uint32_t* AX, const uint32_t* SK, const uint32_t* BX);

void Decryption_3block(uint32_t* PT1, uint32_t* PT2, uint32_t* PT3, const uint32_t* WK, const uint32_t* DSK, const uint32_t* CT1, const uint32_t* CT2, const uint32_t* CT3);