#include <stdio.h>
#include <stdint.h>

extern void Encryption_2block(uint32_t* CT1, uint32_t* CT2, const uint32_t* WK, const uint32_t* SK, const uint32_t* PT1, const uint32_t* PT2);
extern void Decryption_2block(uint32_t* PT1, uint32_t* PT2, const uint32_t* WK, const uint32_t* DSK, const uint32_t* CT1, const uint32_t* CT2);

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

void SKSchedule(uint32_t* SK, const uint32_t* MK)
{
	for (int i = 0; i < 8; i++)
	{
		for (int j = 0; j < 8; j++)
		{
			SK[16 * i + j] = MK[(j - i + 8) & 7] + delta[16 * i + j];
		}
		for (int j = 0; j < 8; j++)
		{
			SK[16 * i + j + 8] = MK[((j - i + 8) & 7) + 8] + delta[16 * i + j + 8];
		}
	}
}

void printETC(uint32_t* MK, uint32_t* PT1, uint32_t* PT2, uint32_t* CT1, uint32_t* CT2)
{
	printf("[KEY]\r\n");
	for (int i = 0; i < 16; i++)
	{
		printf("%lx ", MK[i]);
	}
	printf("\r\n\n");

	printf("[PT1]\r\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%lx ", PT1[i]);
	}
	printf("\r\n\n");

	printf("[PT2]\r\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%lx ", PT2[i]);
	}
	printf("\r\n\n");

	printf("[CT1]\r\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%lx ", CT1[i]);
	}
	printf("\r\n\n");

	printf("[CT2]\r\n");
	for (int i = 0; i < 8; i++)
	{
		printf("%lx ", CT2[i]);
	}
	printf("\r\n\n");
}

int main()
{
	uint32_t MK[16] = { 0xff, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00 };
	uint32_t WK[8] = { 0, };
	uint32_t SK[128] = { 0, };
	uint32_t DSK[128] = { 0, };

	uint32_t PT1[8] = { 0, }; //CT: f2 03 4f d9 ae 18 f4 00
	//uint32_t PT2[8] = { 0, };
	//uint32_t PT2[8] = { 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00 }; //CT: F0 DF 54 F0 64 E6 DB 63
	uint32_t PT2[8] = { 0xef, 0xcd, 0xab, 0x89, 0x67, 0x45, 0x23, 0x01 }; //CT: 84 26 A2 27 93 29 AA 73
	//uint32_t PT2[8] = { 0x14, 0x4a, 0xa8, 0xeb, 0xe2, 0x6b, 0x1e, 0xb4 }; //CT: 3C 04 2B CC 9A 84 7C 5B

	uint32_t CT1[8] = { 0, };
	uint32_t CT2[8] = { 0, };
	// uint32_t CT1[8] = { 0xf2, 0x03, 0x4f, 0xd9, 0xae, 0x18, 0xf4, 0x00 };
	// uint32_t CT2[8] = { 0x84, 0x26, 0xa2, 0x27, 0x93, 0x29, 0xaa, 0x73 };

	//키스케줄
	WKSchedule(WK, MK);
	SKSchedule(SK, MK); 

	//key packing
	for (int i = 0; i < 8; i++)
	{
		WK[i] = (WK[i] << 16) + WK[i];
	}
	for (int i = 0; i < 128; i++)
	{
		SK[i] &= 0xff;
		SK[i] = (SK[i] << 16) + SK[i];
	}

	for (int i = 0; i < 128; i++)
	{
		DSK[i] = SK[127 - i];
	}
	printf("aaaaaaaaaa");
	Encryption_2block(CT1, CT2, WK, SK, PT1, PT2);
	//printETC(MK, PT1, PT2, CT1, CT2);
	for(int i = 0;i<8;i++)
	{
		printf("%lx ", CT1[i]);
	}
	
	printf("bbbbbbbbb");
	Decryption_2block(PT1, PT2, WK, DSK, CT1, CT2);

	//Decryption_2block 함수의 주석을 풀면 print가 안됨, Encryption_2block 후의 printETC도 안됨
	//디버깅해보면 원래는 printETC를 실행하면서 출력들이 한 번에 나오는데
	//밑에 Decryption_2block가 주석이 안되어 있으면 printETC가 안 돌아감
	// 정리: Decryption_2block가 주석이 안되어 있으면 Encryption_2block이 끝나고 printf 관련은 모두 안 됨
	//		주석만 되어있으면 Encryption_2block 끝나고 printf 잘 됨

	printf("cccccccc");
	printETC(MK, PT1, PT2, CT1, CT2);

	return 0;
}