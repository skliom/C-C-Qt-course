/*Склемин Дмитрий*/

/*Чтение текста из файла (до 100000 символов) и считывание размера символов в файле*/



#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

static int count_ch = 100000;					//максимальный размер массива

int main()
{
	srand(time(NULL));
	FILE *creat_file;					//создаем указатель на переменную файла

	unsigned int enter_size = 100001;			//присваиваем значение на один больше, чтобы запустить цикл
	printf ("Программа определяет количество символов в файле.\n");
	// проверка введенного значения пользователем
	while (enter_size > 100000)
	{
		printf ("Введите количество символов создаваемого файла не более 100000:\n");
		scanf("%u" , &enter_size);
	} 
	//end проверка введенного значения пользователем

	char name_file[] = "file100000.txt";				//название файла	
	

	//открываем файл
	if ((creat_file = fopen (name_file, "w")) == NULL)
	{
		printf("Не возможно создать файл \"%s\"", name_file);
		exit (1);
	}
	//end открываем файл

	int b[10] = {0};

	char rand_ch[count_ch+1];	
	char rand_temp;
	//заполняем массив случайными числами

	int endStr;
	for (int i = 0; i < enter_size; i++)
	{
		//выбираем символы букв
		do 
		{	
			rand_temp = rand()%122;			
		} while (rand_temp <= 64 || rand_temp >= 91 && rand_temp <= 96);
		//end выбираем символы букв

	rand_ch[i] = rand_temp;					//добавляем символ в массив
	endStr = i+1;
	}
	rand_ch[endStr] = '\0';					//дописываем в конце символ конца строки!!!
	//end заполняем массив случайными числами

	
	//записываем символы в файл и выводим сообщения о записи файла
	if (fputs(rand_ch, creat_file) != -1)
	{
		printf("Файл \"%s\" создан\n", name_file);
	}
	fclose(creat_file);

	FILE *open_file;

	//открываем файл
	if ((open_file = fopen (name_file, "r")) == NULL)
	{
		printf("Не возможно открыть файл \"%s\"", name_file);
		exit (1);
	}
	//end открываем файл

	char get_ch[count_ch];					//архив для считывания файла
	

	int i = 0;
	while (get_ch[i] = fgetc(open_file) != EOF)		//считываем файл пока не достигнем конца файла
	{
		i++;
	}

	int size = strlen(get_ch);				//считаем полученные символы.

	printf ("Количество символов в файле \"%s\" = %d\n" , name_file , size);

	fclose(open_file);	
	return 0;

}
