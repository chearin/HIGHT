#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

#include "encryption.h"
#include "decryption.h"

void printETC(uint32_t* MK, uint32_t* PT1, uint32_t* PT2, uint32_t* PT3, uint32_t* CT1, uint32_t* CT2, uint32_t* CT3)
{
	printf("[KEY]\n");
	for (int i = 0; i < 16; i++)
	{
		printf("%02x ", MK[i]);
	}
	printf("\n\n");

	printf("[PT1]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02x ", PT1[i]);
	}
	printf("\n\n");

	printf("[PT2]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02x ", PT2[i]);
	}
	printf("\n\n");

	printf("[PT3]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02x ", PT3[i]);
	}
	printf("\n\n");

	printf("[CT1]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02x ", CT1[i]);
	}
	printf("\n\n");

	printf("[CT2]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02x ", CT2[i]);
	}
	printf("\n\n");

	printf("[CT3]\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%02x ", CT3[i]);
	}
	printf("\n\n");
}

void printDelta()
{
	uint8_t s[134] = { 0, };

	GenSTable(s);
	printf("[Delta Table]");
	for (int i = 0; i < 128; i++)
	{
		if (i % 8 == 0)
		{
			printf("\n");
		}
		printf("0x%02X ", GenDelta(s + i));
	}
	printf("\n");
}

int main()
{
	uint32_t MK[16] = { 0xff, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00 };
	uint32_t WK[8] = { 0, };
	uint32_t SK[128] = { 0, };
	uint32_t DSK[128] = { 0, };

	uint32_t PT1[8] = { 0, }; //CT: f2 03 4f d9 ae 18 f4 00
	//uint32_t PT2[8] = { 0, };
	uint32_t PT2[8] = { 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00 }; //CT: F0 DF 54 F0 64 E6 DB 63
	//uint32_t PT3[8] = { 0, };
	//uint32_t PT3[8] = { 0xef, 0xcd, 0xab, 0x89, 0x67, 0x45, 0x23, 0x01 }; //CT: 84 26 A2 27 93 29 AA 73
	uint32_t PT3[8] = { 0x14, 0x4a, 0xa8, 0xeb, 0xe2, 0x6b, 0x1e, 0xb4 }; //CT: 3C 04 2B CC 9A 84 7C 5B

	uint32_t CT1[8] = { 0, };
	uint32_t CT2[8] = { 0, };
	uint32_t CT3[8] = { 0, };

	//키스케줄
	WKSchedule(WK, MK);
	SKSchedule(SK, MK);

	//key packing
	for (int i = 0; i < 8; i++)
	{
		WK[i] = (WK[i] << 24) + (WK[i] << 12) + WK[i];
	}
	for (int i = 0; i < 128; i++)
	{
		SK[i] &= 0xff;
		SK[i] = (SK[i] << 24) + (SK[i] << 12) + SK[i];
	}

	for (int i = 0; i < 128; i++)
	{
		DSK[i] = SK[127 - i];
	}

	Encryption_3block(CT1, CT2, CT3, WK, SK, PT1, PT2, PT3);
	printETC(MK, PT1, PT2, PT3, CT1, CT2, CT3);
	Decryption_3block(PT1, PT2, PT3, WK, DSK, CT1, CT2, CT3);
	printETC(MK, PT1, PT2, PT3, CT1, CT2, CT3);

	return 0;
}