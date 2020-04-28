/*Склемин Дмитрий*/

/*Заполнение массива char случайными буквами*/


#include <stdio.h>
#include <stdlib.h>
#include <time.h>


int main()
{
	srand(time(NULL));

	char rand_ch[1000];
	char rand_temp;


	//заполняем массив случайными числами
	for (int i=0; i < 1000; i++)
	{
		//выбираем символы букв
		do 
		{		
	 			
			rand_temp = rand()%122;			
		} while (rand_temp <= 64 || rand_temp >= 91 && rand_temp <= 96);
		//end выбираем символы букв
		rand_ch[i] = rand_temp;		//добавляем символ в массив
	}	
	//end заполняем массив случайными числами

	for (int i = 0 ; i < 1000 ; i++)
	{
		printf("%c" , rand_ch[i]);
	}
	printf("\n");

	return 0;
}
