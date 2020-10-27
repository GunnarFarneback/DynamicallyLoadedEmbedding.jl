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

    return 1;
}
