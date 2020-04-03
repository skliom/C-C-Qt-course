/*Склемин Д.В.*/

/*переполнение char*/

#include <stdio.h>

int main(){

char x = 121;

printf("Было: символ x = %c, номер x = %d\n", x, x);

x = x + 56 + 127;

printf("Стало: символ x = %c, номер x = %d\n", x, x);

return 0;

}
