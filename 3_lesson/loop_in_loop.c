/*Склемин Д.В.*/



#include <stdio.h>

int main(){

/*цикл for в while*/
	int i = 0;
	int sum = 0;
printf("цикл for в while\n");
while (sum < 10) 
	{
	for(i = 0; i < 10; i++)
		{		
		printf("i = %d, ", i);
		}
	sum ++;
	printf("sum = %d;\n", sum);
	}	
/*end цикл for в while*/



/*цикл for в do-while*/
i = 0;
sum = 0;
printf("\nfor в do-while\n");
do {
	for(i = 0; i < 10; i++)
		{		
		printf("i = %d, ", i);
		}
	sum ++;
	printf("sum = %d;\n", sum);
} while (sum < 10);

/*end цикл for в do-while*/

return 0;

}
