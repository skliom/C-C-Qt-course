/*Склемин Дмитрий*/

/*рекурсия*/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int sum_date (int sum, int date[], int count)
{
	//в функцию передаем начальное значение суммы чисел (в основной программе передается 0),
	//массив чисел даты и размер массива данных (значений даты вместе с точками - 10, поэтому размер массива 9)
	if (count >= 0) 
	{
		//если встречается точка, а это соответствует значению -2, то это значение пропускаем и не суммируем
		if (date[count] >= 0)								
			return date[count] + sum_date (sum, date, count - 1);
		else
			return sum_date (sum, date, count - 1);
	}
	else
		{
		return sum;
		}
}



int main()
{
	char *enter_date;
	int i_date[10];
	enter_date = (char*)malloc(11);					//выделяем необходимое количество памяти, 10 значений + /0
	printf ("Введите день рождения, пример - 08.07.1980\n");		
	scanf ("%10s", enter_date);
	for (int i = 0; i < 10; i++)
	{
		i_date[i] = enter_date[i] - '0';
	}
	
	printf("Сумма чисел даты рождения = %d\n" , sum_date (0, i_date, 9));
	
	return 0;
}
