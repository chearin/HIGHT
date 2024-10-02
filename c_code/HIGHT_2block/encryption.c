#include "encryption.h"

const uint32_t delta[128] = { 0x5A, 0x6D, 0x36, 0x1B, 0x0D, 0x06, 0x03, 0x41, 0x60, 0x30, 0x18, 0x4C, 0x66, 0x33, 0x59, 0x2C, 0x56, 0x2B, 0x15, 0x4A, 0x65, 0x72, 0x39, 0x1C, 0x4E, 0x67, 0x73, 0x79, 0x3C, 0x5E, 0x6F, 0x37, 0x5B, 0x2D, 0x16, 0x0B, 0x05, 0x42, 0x21, 0x50, 0x28, 0x54, 0x2A, 0x55, 0x6A, 0x75, 0x7A, 0x7D, 0x3E, 0x5F, 0x2F, 0x17, 0x4B, 0x25, 0x52, 0x29, 0x14, 0x0A, 0x45, 0x62, 0x31, 0x58, 0x6C, 0x76, 0x3B, 0x1D, 0x0E, 0x47, 0x63, 0x71, 0x78, 0x7C, 0x7E, 0x7F, 0x3F, 0x1F, 0x0F, 0x07, 0x43, 0x61, 0x70, 0x38, 0x5C, 0x6E, 0x77, 0x7B, 0x3D, 0x1E, 0x4F, 0x27, 0x53, 0x69, 0x34, 0x1A, 0x4D, 0x26, 0x13, 0x49, 0x24, 0x12, 0x09, 0x04, 0x02, 0x01, 0x40, 0x20, 0x10, 0x08, 0x44, 0x22, 0x11, 0x48, 0x64, 0x32, 0x19, 0x0C, 0x46, 0x23, 0x51, 0x68, 0x74, 0x3A, 0x5D, 0x2E, 0x57, 0x6B, 0x35, 0x5A };

void WKSchedule(uint32_t* WK, const uint32_t* MK)
{
	WK[0] = MK[12];
	WK[1] = MK[13];
	WK[2] = MK[14];
	WK[3] = MK[15];
	WK[4] = MK[0];
	WK[5] = MK[1];
	WK[6] = MK[2];
	WK[7] = MK[3];
}

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

void SKSchedule(uint32_t* SK, const uint32_t* MK)
{
	uint8_t s[134] = { 0, };

	//GenSTable(s);
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
}

void initialTran(uint32_t* X, const uint32_t* WK, const uint32_t* PT)
{
	X[1] = PT[1];
	X[3] = PT[3];
	X[5] = PT[5];
	X[7] = PT[7];
	X[0] = PT[0] + WK[0];
	X[0] &= 0x00ff00ff;
	X[2] = PT[2] ^ WK[1];
	X[4] = PT[4] + WK[2];
	X[4] &= 0x00ff00ff;
	X[6] = PT[6] ^ WK[3];
}

void finalTran(uint32_t* CT, const uint32_t* WK, const uint32_t* X)
{
	CT[1] = X[1];
	CT[3] = X[3];
	CT[5] = X[5];
	CT[7] = X[7];
	CT[0] = X[0] + WK[4];
	CT[2] = X[2] ^ WK[5];
	CT[4] = X[4] + WK[6];
	CT[6] = X[6] ^ WK[7];
}

//AX: afterX, BX: beforeX
//rotation 1, 2, 7 하나씩 따로 구현
void F0_2block(uint32_t* AX, const uint32_t BX)
{
	uint32_t temp1[3] = { 0, };
	uint32_t temp2[3] = { 0, };

	//X<<<1
	temp1[0] = BX << 1;
	temp2[0] = BX >> 7;
	temp1[0] ^= temp2[0];
	temp1[0] &= 0x00ff00ff;

	//X<<<2
	temp1[1] = BX << 2;
	temp2[1] = BX >> 6;
	temp1[1] ^= temp2[1];
	temp1[1] &= 0x00ff00ff;

	//X<<<7
	temp1[2] = BX << 7;
	temp2[2] = BX >> 1;
	temp1[2] ^= temp2[2];
	temp1[2] &= 0x00ff00ff;

	*AX = temp1[0] ^ temp1[1] ^ temp1[2];
}

//rotation 3, 4, 6 하나씩 따로 구현
void F1_2block(uint32_t* AX, const uint32_t BX)
{
	uint32_t temp1[3] = { 0, };
	uint32_t temp2[3] = { 0, };

	//X<<<3
	temp1[0] = BX << 3;
	temp2[0] = BX >> 5;
	temp1[0] ^= temp2[0];
	temp1[0] &= 0x00ff00ff;

	//X<<<4
	temp1[1] = BX << 4;
	temp2[1] = BX >> 4;
	temp1[1] ^= temp2[1];
	temp1[1] &= 0x00ff00ff;

	//X<<<6
	temp1[2] = BX << 6;
	temp2[2] = BX >> 2;
	temp1[2] ^= temp2[2];
	temp1[2] &= 0x00ff00ff;

	*AX = temp1[0] ^ temp1[1] ^ temp1[2];
}

void EncRound(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
{
	uint32_t temp[4] = { 0, };
	uint32_t temp2[4] = { BX[1], BX[3], BX[5], BX[7] }; //AX, BX가 같은 주소일 때를 대비

	AX[1] = BX[0];
	AX[3] = BX[2];
	AX[5] = BX[4];
	AX[7] = BX[6];
	F0_2block(temp, BX[6]);
	F1_2block(temp + 1, BX[0]);
	F0_2block(temp + 2, BX[2]);
	F1_2block(temp + 3, BX[4]);
	AX[0] = temp2[3] ^ (temp[0] + SK[3]);
	AX[0] &= 0x00ff00ff;
	AX[2] = temp2[0] + (temp[1] ^ SK[0]);
	AX[2] &= 0x00ff00ff;
	AX[4] = temp2[1] ^ (temp[2] + SK[1]);
	AX[4] &= 0x00ff00ff;
	AX[6] = temp2[2] + (temp[3] ^ SK[2]);
	AX[6] &= 0x00ff00ff;
}

//마지막 round
void EncRound2(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
{
	uint32_t temp[4] = { 0, };

	AX[0] = BX[0];
	AX[2] = BX[2];
	AX[4] = BX[4];
	AX[6] = BX[6];
	F1_2block(temp, BX[0]);
	F0_2block(temp + 1, BX[2]);
	F1_2block(temp + 2, BX[4]);
	F0_2block(temp + 3, BX[6]);
	AX[1] = BX[1] + (temp[0] ^ SK[0]);
	AX[1] &= 0x00ff00ff;
	AX[3] = BX[3] ^ (temp[1] + SK[1]);
	AX[3] &= 0x00ff00ff;
	AX[5] = BX[5] + (temp[2] ^ SK[2]);
	AX[5] &= 0x00ff00ff;
	AX[7] = BX[7] ^ (temp[3] + SK[3]);
	AX[7] &= 0x00ff00ff;
}

void bitMasking(uint32_t* X, uint8_t n)
{
	for (int i = 0; i < n; i++)
	{
		X[i] &= 0x00ff00ff;
	}
}

void Encryption_2block(uint32_t* CT1, uint32_t* CT2, const uint32_t* WK, const uint32_t* SK, const uint32_t* PT1, const uint32_t* PT2)
{
	uint32_t PT[8] = { 0, };
	uint32_t CT[8] = { 0, };	

	//packing
	for (int i = 0; i < 8; i++)
	{
		PT[i] = (PT2[i] << 16) + PT1[i];
	}

	//initial
	initialTran(CT, WK, PT);
	//1-31round(round 시작전 0x00ff00ff으로 마스킹 필요)
	for (int i = 1; i < 32; i++)
	{
		//bitMasking(CT, 8);
		EncRound(CT, &SK[(i - 1) * 4], CT);
	}
	//32round
	//bitMasking(CT, 8);
	EncRound2(CT, &SK[124], CT);
	//final
	finalTran(CT, WK, CT);	

	//unpacking
	for (int i = 0; i < 8; i++)
	{
		CT1[i] = CT[i] & 0xff;
		CT2[i] = (CT[i] >> 16) & 0xff;
	}
}