/*Склемин Д.В.*/

/*переполнение char*/

#include <stdio.h>

int main(){

double x = 1.7E+308;

printf("Было: x = %e\n", x);

x = x + 1E+307;

printf("Стало: x = %e\n", x);

return 0;

}
