/*Склемин Дмитрий*/

/*Создание 10 файлов с 1000 различными случайными символами*/


#include <stdio.h>
#include <stdlib.h>
#include <time.h>
static int count_ch = 10000;

int main()
{
	srand(time(NULL));
	FILE *creat_file;					//создаем указатель на переменную файла


	char name_file[] = "rand_file";				//название файла	
	

	//открываем файл
	if ((creat_file = fopen (name_file, "w")) == NULL)
	{
		printf("Не возможно создать файл \"%s\"", name_file);
		exit (1);
	}
	//end открываем файл


	char rand_ch[count_ch];
	char rand_temp;
	//заполняем массив случайными числами

	for (int i = 0; i < count_ch; i++)
	{
		//выбираем символы букв
		do 
		{		
	 			
			rand_temp = rand()%122;			
		} while (rand_temp <= 64 || rand_temp >= 91 && rand_temp <= 96);
		//end выбираем символы букв

	rand_ch[i] = rand_temp;					//добавляем символ в массив

	}
	//end заполняем массив случайными числами	
	
	//записываем символы в файл и выводим сообщения о записи файла
	if (fputs(rand_ch, creat_file) != -1)
	{
		printf("Файл \"%s\" создан\n", name_file);
	}
	fclose(creat_file);
	
	char enter_ch;
	printf ("Программа определяет количество повторений символа в файле. \nВведите символ:\n");
	enter_ch = getchar();


	//открываем файл
	if ((creat_file = fopen (name_file, "r")) == NULL)
	{
		printf("Не возможно открыть файл \"%s\"", name_file);
		exit (1);
	}
	//end открываем файл

	char get_ch[count_ch];					//объявляем массив
	
	fgets(get_ch, count_ch + 1 , creat_file);		//считываем значения из файла

	fclose(creat_file);

	//просматривая все значения сравниваем с введенным, увеличиваем счетчкик, если есть совпадения
	int count = 0;
	for (int i = 0; i < count_ch ; i++)
	{
		if (get_ch[i] == enter_ch)
		{
			count++;
		}	
	}
	printf ("Количество символов \"%c\" в файле \"%s\" = %d\n" , enter_ch , name_file , count);
	
	return 0;
}
