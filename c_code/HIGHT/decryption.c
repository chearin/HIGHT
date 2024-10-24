#include "decryption.h"

void Dec_initialTran(uint8_t* X, const uint8_t* WK, const uint8_t* CT)
{
	X[1] = CT[1];
	X[3] = CT[3];
	X[5] = CT[5];
	X[7] = CT[7];
	X[0] = CT[0] - WK[0];
	X[2] = CT[2] ^ WK[1];
	X[4] = CT[4] - WK[2];
	X[6] = CT[6] ^ WK[3];
}

void Dec_finalTran(uint8_t* PT, const uint8_t* WK, const uint8_t* X)
{
	PT[1] = X[1];
	PT[3] = X[3];
	PT[5] = X[5];
	PT[7] = X[7];
	PT[0] = X[0] - WK[0];
	PT[2] = X[2] ^ WK[1];
	PT[4] = X[4] - WK[2];
	PT[6] = X[6] ^ WK[3];
}

void DecRound(uint8_t* AX, const uint8_t* SK, const uint8_t* BX)
{
	uint8_t temp[4] = { 0, };
	uint8_t temp2[4] = { BX[1], BX[3], BX[5], BX[7] };//AX, BX가 같은 주소일 때를 대비

	AX[1] = BX[2];
	AX[3] = BX[4];
	AX[5] = BX[6];
	AX[7] = BX[0];
	F1(temp, BX[0]);
	F0(temp + 1, BX[2]);
	F1(temp + 2, BX[4]);
	F0(temp + 3, BX[6]);
	AX[0] = temp2[0] - (temp[0] ^ SK[3]);
	AX[2] = temp2[1] ^ (temp[1] + SK[2]);
	AX[4] = temp2[2] - (temp[2] ^ SK[1]);
	AX[6] = temp2[3] ^ (temp[3] + SK[0]);
}

//마지막 round
void DecRound2(uint8_t* AX, const uint8_t* SK, const uint8_t* BX)
{
	uint8_t temp[4] = { 0, };

	AX[0] = BX[0];
	AX[2] = BX[2];
	AX[4] = BX[4];
	AX[6] = BX[6];
	F1(temp, BX[0]);
	F0(temp + 1, BX[2]);
	F1(temp + 2, BX[4]);
	F0(temp + 3, BX[6]);
	AX[1] = BX[1] - (temp[0] ^ SK[3]);
	AX[3] = BX[3] ^ (temp[1] + SK[2]);
	AX[5] = BX[5] - (temp[2] ^ SK[1]);
	AX[7] = BX[7] ^ (temp[3] + SK[0]);
}

void Decryption(uint8_t* PT, const uint8_t* MK, const uint8_t* CT)
{
	uint8_t SK[128] = { 0, };
	uint8_t DSK[128] = { 0, };

	//키스케줄
	SKSchedule(SK, MK);
	for (int i = 0; i < 128; i++)
	{
		DSK[i] = SK[127 - i];
	}
	//DSK print
	printf("[DSK]\n");
	for (int i = 0; i < 32; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			printf("0x%02X ", DSK[i * 4 + j]);
		}
		printf("\n");
	}
	printf("\n");

	//initial
	Dec_initialTran(PT, MK, CT);

	printf("[IT]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02X ", PT[i]);
	}
	printf("\n");

	//1-31round
	for (int i = 1; i < 32; i++)
	{
		DecRound(PT, DSK + (i - 1) * 4, PT);
		printf("[X%d]\n", i);
		for (int j = 0; j < 8; j++)
		{
			printf("%02X ", PT[j]);
		}
		printf("\n");
	}
	//32round
	DecRound2(PT, DSK + 124, PT);

	printf("[X32]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02X ", PT[i]);
	}
	printf("\n");

	//final
	Dec_finalTran(PT, MK + 12, PT);

	printf("[FT]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02X ", PT[i]);
	}
	printf("\n");
}