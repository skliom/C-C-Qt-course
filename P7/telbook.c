/*Склемин Дмитрий*/

/*Телефонный справочник*/


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>


struct Telefone
{	
	long unsigned int number;
	char name[20];
}Items [50];


void AddItem(struct Telefone* curSt, int cur_num);
void View(struct Telefone curSt);
void findStr (struct Telefone curSt, char*name_f, int n_user);
int GetNum (int total);
void save(struct Telefone curSt);



int main ()
{
	int num = 0; 
	int menuNum = 0; 
	char find [20];
	int max_str = 0;
	printf ("\n\n\n1 - Добавить поле \n2 - Сохранить в файл\n3 - Вывести информацию\n4 - Поиск по телефонной книжке\n\nВыберите нужный номер: ");
	menuNum = GetNum(5);
	switch (menuNum)
	{
		case 1:
			printf ("Введите макс количество записей справочника:\n");
			scanf("%d", &max_str);			
			do 
			{
 		 		AddItem(&Items[num], num);
		   		printf("max_str=%d  name = %s ;   number= %lu\n", max_str, Items[num].name, Items[num].number);					
				++num;
			}
			while (num < max_str);
			main ();
		case 2:
			for (int i = 0;	i <  max_str ;	i++)
				save (Items[i]);
			
			printf ("Сохранение успешно выполнено\n");
			main ();

		case 3:
			for (int i = 0;	i <  max_str ;	i++) 
				printf("max_str=%d   Имя = %s ; номер телефона= %lu\n", max_str, Items[i].name, Items[i].number);
			
			main ();
		case 4:
			printf ("Введите имя для поиска:\n");
			scanf ("%s", find);			
			for (int i = 0;	i <  max_str ; i++)
				findStr (Items[i], find, i+1);
			main ();	

	}
	return 0;
}

int GetNum (int total)
{ 
int number;
    char str[100];
    scanf("%s", str); 
    while (sscanf(str, "%d", &number) != 1 || number < 1 || number > total) 
	{
        printf("Введено неправильно! Еще раз: "); 
        scanf("%s", str); 
	}
	return number;
}


void AddItem(struct Telefone* curSt, int cur_num) 
{  
	
	char name_user[20];
	unsigned long int number_user;
	printf ("Введи имя %d-го абонента и телефон:\n", cur_num+1);
	scanf ("%s %lu", name_user, &number_user);
	strcpy (curSt->name,name_user); 
	curSt->number = number_user;
}


void View(struct Telefone curSt)
{

printf("name = %s ; number= %lu\n", curSt.name, curSt.number);	

}

void findStr (struct Telefone curSt, char* name_f, int n_user)
{
	if (strcmp (curSt.name, name_f) == 0) 
	{ 
		printf ("Запись найдена! №%d!\n Номер телефона:%lu\n\n", n_user, curSt.number);
	} 
}


void save(struct Telefone curSt)
{
	FILE* fp;
	fp = fopen ("File.txt", "a+");
	if ((fp = fopen ("File.txt", "a+")) == NULL)
	{
		printf("Файл не создан\n");
	}
	
	fprintf (fp, " Name:%s Number:%lu\n", curSt.name, curSt.number);
	fclose(fp);
}





