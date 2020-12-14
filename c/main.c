#include "julia_embedding.h"
#include "julia_cfunctions.h"
#include <stdlib.h>
#include <stdio.h>

/* Mutually recursive fibonacci implementation which bounces back and
 * forth between C and Julia. `mutual_fibonacci` is defined in Julia
 * and loaded as a `cfunction`.
 *
 * Obviously this is an inefficient way to compute fibonacci numbers
 * but a nice showcase of callbacks.
 */
static int fibonacci(int n)
{
    if (n <= 1)
        return n;
    return mutual_fibonacci(n - 1, fibonacci) +
           mutual_fibonacci(n - 2, fibonacci);
}

int main(int argc, const char **argv)
{
    const char *system_image_path = NULL;
    if (argc > 1)
        system_image_path = argv[1];

    const char *julia_cfunctions_path = "../src/julia_cfunctions.jl";
    if (argc > 2)
        julia_cfunctions_path = argv[2];
    
    const char *version_string = julia_preinitialize();
    /* The primary reason for making the version string easily
     * available is that system images are version dependent and this
     * gives an opportunity to find an appropriate custom system
     * image.
     *
     * See https://github.com/JuliaLang/PackageCompiler.jl for making
     * your own system images.
     *
     * If you have no use for the version string,
     * `julia_preinitialize` does not need to be called.
     */
    printf("Julia version %s\n", version_string);

    /* Initialize Julia. First argument is the path to the Julia file
     * that creates the `cfunction` pointers that we load in
     * `julia_cfunctions.c`. Second argument is the path of the system
     * image to start Julia with. If this is NULL or an empty string,
     * the default system image is loaded.
     */
    if (!julia_initialize(julia_cfunctions_path, system_image_path))
        return EXIT_FAILURE;

    /* Load the `cfunction` pointers defined in
     * `julia_cfunctions.c`/`julia_cfunctions.h`.
     */
    if (!load_julia_cfunctions()) {
        return julia_exit(EXIT_FAILURE);
    }

    /* Test the Julia `cfunctions`. */
    printf("%3.1f\n", julia_sind(30.0));

    printf("fibonacci(10) = %d\n", fibonacci(10));

    int xi[4] = {1, 1, 1, 0};
    float xf[3] = {0.0, 0.5, 1.0};

    add_element_number_int(xi, 4);
    add_element_number_float(xf, 3);

    printf("xi =");
    for (int i = 0; i < 4; i++) {
        printf(" %d", xi[i]);
    }
    printf("\n");

    printf("xf =");
    for (int i = 0; i < 3; i++) {
        printf(" %3.1f", xf[i]);
    }
    printf("\n");

    /* Test that exceptions are handled gracefully. */
    julia_eval_string("function this_function_has_no_methods end; this_function_has_no_methods()", "Exception test: ");
    fflush(stdout);

    return julia_exit(EXIT_SUCCESS);
}
