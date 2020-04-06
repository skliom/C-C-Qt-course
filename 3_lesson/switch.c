/*Склемин Д.В.*/

/*Использование ветвления switch-case.*/


#include <stdio.h>

int main(){

int x;

printf("Введите цифру не больше 10: ");
scanf("%d", &x);
printf("\n");

switch (x)

	{

	case 1: printf("Первая буква цифры - О\n");
	break;

	case 2: printf("Первая буква цифры - Д\n");
	break;

	case 3: printf("Первая буква цифры - Т\n");
	break;

	case 4: printf("Первая буква цифры - Ч\n");
	break;

	case 5: printf("Первая буква цифры - П\n");
	break;

	case 6: printf("Первая буква цифры - Ш\n");
	break;

	case 7: printf("Первая буква цифры - С\n");
	break;

	case 8: printf("Первая буква цифры - В\n");
	break;

	case 9: printf("Первая буква цифры - Д\n");
	break;

	case 10: printf("Первая буква цифры - Д\n");
	break;

	default: printf("Ввели цифру больше 10\n");
	break;

	}

return 0;

}
