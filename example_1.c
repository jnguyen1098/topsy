#include <stdio.h>

typedef struct lmao_struct {
    int num_lmaos;
    char LMAOS[];
} LMAO;

void parse_something(void)
{
    parse_preprocedure_1();
    parse_preprocedure_2();
    parse_preprocedure_3();
}

int main(void)
{
    parse_something();
    return 0;
}
