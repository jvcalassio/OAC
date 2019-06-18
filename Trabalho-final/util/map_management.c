/**
 * Gerenciamento de sprites de mapa do jogo
 * Recebe um byte referente a qual fase, e envia os
bytes correspondentes, ate o final

 * gcc map_management.c rs232.c -Wall -Wextra -o2 -o map_management
 */

#include <stdlib.h>
#include <stdio.h>
#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif
#include "rs232.h"

int main()
{
	int i, n;
	int cport_nr = 2, /* usar o número da COM - 1 */
		bdrate = 115200;

	unsigned char buf[4096], num;

	char mode[] = {'8', 'N', '2', 0};

	if (RS232_OpenComport(cport_nr, bdrate, mode))
	{
		printf("Can not open comport\n");
		return (0);
	}

	while (1)
	{
		Sleep(10);

		// recebe n bytes no buffer (maximo 4096)
		n = RS232_PollComport(cport_nr, buf, 4096);
		if (n != 1)
			printf("");
		else
		{
			printf("Mapa %d solicitado.\n", buf[0]);

			FILE *fd;
			if (buf[0] == 1)
				fd = fopen("../sprites/bin/fase1.s", "r");
			else if (buf[0] == 2)
				fd = fopen("../sprites/bin/fase2.s", "r");
			else
				continue;
			

			char temp0[20], temp1[20];
			int temp2, temp3;
			fscanf(fd, "%s %s %d, %d", temp0, temp1, &temp2, &temp3);
			fscanf(fd, "%s", temp0);

			printf("Enviando mapa...\n");

			int enviar;
			while (fscanf(fd, "%d,", &enviar) == 1)
			{
				RS232_SendByte(cport_nr, enviar);
				//Sleep(0.15);
			}

			printf("Mapa enviado.\n");
			fclose(fd);
		}
	}
	return (0);
}
