#include "decryption.h"

void Dec_initialTran(uint32_t* X, const uint32_t* WK, const uint32_t* CT)
{
	X[1] = CT[1];
	X[3] = CT[3];
	X[5] = CT[5];
	X[7] = CT[7];
	
	X[0] = CT[0] | 0xff00ff00;
	X[0] = X[0] - WK[4];
	X[0] &= 0x00ff00ff;
	X[2] = CT[2] ^ WK[5];
	X[4] = CT[4] | 0xff00ff00;
	X[4] = X[4] - WK[6];
	X[4] &= 0x00ff00ff;
	X[6] = CT[6] ^ WK[7];
}

void Dec_finalTran(uint32_t* PT, const uint32_t* WK, const uint32_t* X)
{
	PT[1] = X[1];
	PT[3] = X[3];
	PT[5] = X[5];
	PT[7] = X[7];
	PT[0] = X[0] | 0xff00ff00;
	PT[0] = PT[0] - WK[0];
	PT[0] &= 0x00ff00ff;
	PT[2] = X[2] ^ WK[1];
	PT[4] = X[4] | 0xff00ff00;
	PT[4] = PT[4] - WK[2];
	PT[4] &= 0x00ff00ff;
	PT[6] = X[6] ^ WK[3];
}

void DecRound(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
{
	uint32_t temp[4] = { 0, };
	uint32_t temp2[4] = { BX[1], BX[3], BX[5], BX[7] };//AX, BX가 같은 주소일 때를 대비

	AX[1] = BX[2];
	AX[3] = BX[4];
	AX[5] = BX[6];
	AX[7] = BX[0];
	F1_2block(temp, BX[0]);
	F0_2block(temp + 1, BX[2]);
	F1_2block(temp + 2, BX[4]);
	F0_2block(temp + 3, BX[6]); 
	temp[0] &= 0x00ff00ff;
	temp[1] &= 0x00ff00ff;
	temp[2] &= 0x00ff00ff;
	temp[3] &= 0x00ff00ff;
	temp2[0] |= 0xff00ff00;
	temp2[2] |= 0xff00ff00;
	AX[0] = temp2[0] - (temp[0] ^ SK[3]);
	AX[2] = temp2[1] ^ (temp[1] + SK[2]);
	AX[4] = temp2[2] - (temp[2] ^ SK[1]);
	AX[6] = temp2[3] ^ (temp[3] + SK[0]);
	AX[0] &= 0x00ff00ff;
	AX[2] &= 0x00ff00ff;
	AX[4] &= 0x00ff00ff;
	AX[6] &= 0x00ff00ff;
}

//마지막 round
void DecRound2(uint32_t* AX, const uint32_t* SK, const uint32_t* BX)
{
	uint32_t temp[4] = { 0, };
	uint32_t temp2[4] = { BX[1], BX[3], BX[5], BX[7] };

	AX[0] = BX[0];
	AX[2] = BX[2];
	AX[4] = BX[4];
	AX[6] = BX[6];
	F1_2block(temp, BX[0]);
	F0_2block(temp + 1, BX[2]);
	F1_2block(temp + 2, BX[4]);
	F0_2block(temp + 3, BX[6]);
	temp[0] &= 0x00ff00ff;
	temp[1] &= 0x00ff00ff;
	temp[2] &= 0x00ff00ff;
	temp[3] &= 0x00ff00ff;
	temp2[0] |= 0xff00ff00;
	temp2[2] |= 0xff00ff00;
	AX[1] = temp2[0] - (temp[0] ^ SK[3]);
	AX[3] = temp2[1] ^ (temp[1] + SK[2]);
	AX[5] = temp2[2] - (temp[2] ^ SK[1]);
	AX[7] = temp2[3] ^ (temp[3] + SK[0]);
	AX[1] &= 0x00ff00ff;
	AX[3] &= 0x00ff00ff;
	AX[5] &= 0x00ff00ff;
	AX[7] &= 0x00ff00ff;
}

void Decryption_2block(uint32_t* PT1, uint32_t* PT2, const uint32_t* WK, const uint32_t* DSK, const uint32_t* CT1, const uint32_t* CT2)
{
	uint32_t PT[8] = { 0, };
	uint32_t CT[8] = { 0, };

	//packing
	for (int i = 0; i < 8; i++)
	{
		CT[i] = (CT2[i] << 16) + CT1[i];
	}

	//initial
	Dec_initialTran(PT, WK, CT);
	//1-31round
	for (int i = 1; i < 32; i++)
	{
		DecRound(PT, DSK + (i - 1) * 4, PT);
	}
	//32round
	DecRound2(PT, DSK + 124, PT);
	//final
	Dec_finalTran(PT, WK, PT);

	//unpacking
	for (int i = 0; i < 8; i++)
	{
		PT1[i] = PT[i] & 0xff;
		PT2[i] = (PT[i] >> 16) & 0xff;
	}
}