/*Склемин Дмитрий*/

/*Использование goto*/


#include <stdio.h>

int main()
{
	
	int i = 1;			//присваиваем начальное значение
loop: 					// лейбл

	printf("i= %d \n", i);		//выводим значения на экран

	if (i < 100) 			//если значение меньше 100
		{
		i++;			//увеличиваем на единицу
		goto loop;		//отправляем делать заново		
		}
	return 0;
}
