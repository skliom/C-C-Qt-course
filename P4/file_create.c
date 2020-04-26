/*Склемин Дмитрий*/

/*Создание 10 файлов с 1000 различными случайными символами*/


#include <stdio.h>
#include <stdlib.h>
#include <time.h>


int main()
{
	srand(time(NULL));
	FILE *creat_file;						//создаем указатель на переменную файла
	
	for (int j = 0 ; j < 10 ; j++)
	{
		char name_file[12];				//формируем название файла	
		sprintf (name_file, "%s%d", "rand_file_", j);		

		//открываем файл
		if ((creat_file = fopen (name_file, "w")) == NULL)
		{
			printf("Не возможно создать файл \"%s\"", name_file);
			exit (1);
		}
		//end открываем файл
	
		char rand_ch[1000+1];
		char rand_temp;
		for (int i=0; i < 1000; i++)
		{
			//выбираем символы цифр, букв
			do 
			{		
		 			
				rand_temp = rand()%122;			
			} while (rand_temp <= 47 || rand_temp >= 58 && rand_temp <= 64 || rand_temp >= 91 && rand_temp <= 96);
		//end выбираем символы цифр, букв

		rand_ch[i] = rand_temp;		//добавляем символ в общую переменную
		}	
	
		//выводим сообщения о записи файлов
		if (fputs(rand_ch, creat_file) != -1)
		{
			printf("Файл \"%s\" создан\n", name_file);
		}
	
	
		fclose(creat_file);
	}

	return 0;
}
