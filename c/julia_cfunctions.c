#include "julia_embedding.h"
#include "julia_cfunctions.h"

int load_julia_cfunctions()
{
    julia_sind = get_cfunction_pointer("julia_sind");
    if (!julia_sind)
        return 0;

    mutual_fibonacci = get_cfunction_pointer("mutual_fibonacci_ptr");
    if (!mutual_fibonacci)
        return 0;

    add_element_number_int = get_cfunction_pointer("add_element_number_int");
    if (!add_element_number_int)
        return 0;

    add_element_number_float = get_cfunction_pointer("add_element_number_float");
    if (!add_element_number_float)
        return 0;

    return 1;
}
