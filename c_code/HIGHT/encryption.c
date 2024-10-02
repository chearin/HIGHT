#include "encryption.h"

const uint32_t delta[128] = { 0x5A, 0x6D, 0x36, 0x1B, 0x0D, 0x06, 0x03, 0x41, 0x60, 0x30, 0x18, 0x4C, 0x66, 0x33, 0x59, 0x2C, 0x56, 0x2B, 0x15, 0x4A, 0x65, 0x72, 0x39, 0x1C, 0x4E, 0x67, 0x73, 0x79, 0x3C, 0x5E, 0x6F, 0x37, 0x5B, 0x2D, 0x16, 0x0B, 0x05, 0x42, 0x21, 0x50, 0x28, 0x54, 0x2A, 0x55, 0x6A, 0x75, 0x7A, 0x7D, 0x3E, 0x5F, 0x2F, 0x17, 0x4B, 0x25, 0x52, 0x29, 0x14, 0x0A, 0x45, 0x62, 0x31, 0x58, 0x6C, 0x76, 0x3B, 0x1D, 0x0E, 0x47, 0x63, 0x71, 0x78, 0x7C, 0x7E, 0x7F, 0x3F, 0x1F, 0x0F, 0x07, 0x43, 0x61, 0x70, 0x38, 0x5C, 0x6E, 0x77, 0x7B, 0x3D, 0x1E, 0x4F, 0x27, 0x53, 0x69, 0x34, 0x1A, 0x4D, 0x26, 0x13, 0x49, 0x24, 0x12, 0x09, 0x04, 0x02, 0x01, 0x40, 0x20, 0x10, 0x08, 0x44, 0x22, 0x11, 0x48, 0x64, 0x32, 0x19, 0x0C, 0x46, 0x23, 0x51, 0x68, 0x74, 0x3A, 0x5D, 0x2E, 0x57, 0x6B, 0x35, 0x5A };

void GenSTable(uint8_t* s)
{
	s[0] = 0;
	s[1] = 1;
	s[2] = 0;
	s[3] = 1;
	s[4] = 1;
	s[5] = 0;
	s[6] = 1;
	for (int i = 1; i < 128; i++)
	{
		s[i + 6] = s[i + 2] ^ s[i - 1];
	}
}

uint8_t GenDelta(const uint8_t* s)
{
	return (s[6] << 6) ^ (s[5] << 5) ^ (s[4] << 4) ^ (s[3] << 3) ^ (s[2] << 2) ^ (s[1] << 1) ^ s[0];
}

void SKSchedule(uint8_t* SK, const uint8_t* MK)
{
	uint8_t s[134] = { 0, };

	GenSTable(s);
	for (int i = 0; i < 8; i++)
	{
		for (int j = 0; j < 8; j++)
		{
			//SK[16 * i + j] = MK[(j - i + 8) & 7] + GenDelta(s + 16 * i + j);
			SK[16 * i + j] = MK[(j - i + 8) & 7] + delta[16 * i + j];
		}
		for (int j = 0; j < 8; j++)
		{
			//SK[16 * i + j + 8] = MK[((j - i + 8) & 7) + 8] + GenDelta(s + 16 * i + j + 8);
			SK[16 * i + j + 8] = MK[((j - i + 8) & 7) + 8] + delta[16 * i + j + 8];
		}
	}
	printf("[Delta]\n");
	for (int i = 0; i < 16; i++)
	{
		for (int j = 0; j < 8; j++)
		{
			printf("0x%02X ", GenDelta(s + 8 * i + j));
		}
		printf("\n");
	}
	printf("\n");
}

void initialTran(uint8_t* X, const uint8_t* WK, const uint8_t* PT)
{
	X[1] = PT[1];
	X[3] = PT[3];
	X[5] = PT[5];
	X[7] = PT[7];
	X[0] = PT[0] + WK[0];
	X[2] = PT[2] ^ WK[1];
	X[4] = PT[4] + WK[2];
	X[6] = PT[6] ^ WK[3];
}

void finalTran(uint8_t* CT, const uint8_t* WK, const uint8_t* X)
{
	CT[1] = X[1];
	CT[3] = X[3];
	CT[5] = X[5];
	CT[7] = X[7];
	CT[0] = X[0] + WK[0];
	CT[2] = X[2] ^ WK[1];
	CT[4] = X[4] + WK[2];
	CT[6] = X[6] ^ WK[3];
}

//AX: afterX, BX: beforeX
void Lrotation(uint8_t* AX, const uint8_t BX, const uint8_t n)
{
	*AX = (BX << n) ^ (BX >> (8 - n));
}

void F0(uint8_t* AX, const uint8_t BX)
{
	uint8_t temp[3] = { 0, };

	Lrotation(temp, BX, 1);
	Lrotation(temp + 1, BX, 2);
	Lrotation(temp + 2, BX, 7);
	*AX = temp[0] ^ temp[1] ^ temp[2];
}

void F1(uint8_t* AX, const uint8_t BX)
{
	uint8_t temp[3] = { 0, };

	Lrotation(temp, BX, 3);
	Lrotation(temp + 1, BX, 4);
	Lrotation(temp + 2, BX, 6);
	*AX = temp[0] ^ temp[1] ^ temp[2];
}

void EncRound(uint8_t* AX, const uint8_t* SK, const uint8_t* BX)
{
	uint8_t temp[4] = { 0, };
	uint8_t temp2[4] = { BX[1], BX[3], BX[5], BX[7] };//AX, BX가 같은 주소일 때를 대비

	AX[1] = BX[0];
	AX[3] = BX[2];
	AX[5] = BX[4];
	AX[7] = BX[6];
	F0(temp, BX[6]);
	F1(temp + 1, BX[0]);
	F0(temp + 2, BX[2]);
	F1(temp + 3, BX[4]);
	AX[0] = temp2[3] ^ (temp[0] + SK[3]);
	AX[2] = temp2[0] + (temp[1] ^ SK[0]);
	AX[4] = temp2[1] ^ (temp[2] + SK[1]);
	AX[6] = temp2[2] + (temp[3] ^ SK[2]);	
}

//마지막 round
void EncRound2(uint8_t* AX, const uint8_t* SK, const uint8_t* BX)
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
	AX[1] = BX[1] + (temp[0] ^ SK[0]);
	AX[3] = BX[3] ^ (temp[1] + SK[1]);
	AX[5] = BX[5] + (temp[2] ^ SK[2]);
	AX[7] = BX[7] ^ (temp[3] + SK[3]);
}

void Encryption(uint8_t* CT, const uint8_t* MK, const uint8_t* PT)
{
	uint8_t SK[128] = { 0, };

	//키스케줄
	SKSchedule(SK, MK);

	//SK print
	printf("[SK]\n");
	for (int i = 0; i < 32; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			printf("0x%02X ", SK[i * 4 + j]);
		}
		printf("\n");
	}
	printf("\n");

	//initial
	initialTran(CT, MK + 12, PT);

	printf("[IT]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02X ", CT[i]);
	}
	printf("\n");

	//1-31round
	for (int i = 1; i < 32; i++)
	{
		EncRound(CT, SK + (i - 1) * 4, CT);
		printf("[X%d]\n", i);
		for (int j = 0; j < 8; j++)
		{
			printf("%02X ", CT[j]);
		}
		printf("\n");
	}
	//32round
	EncRound2(CT, SK + 124, CT);

	printf("[X32]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02X ", CT[i]);
	}
	printf("\n");

	//final
	finalTran(CT, MK, CT);
	
	printf("[FT]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02X ", CT[i]);
	}
	printf("\n");
}