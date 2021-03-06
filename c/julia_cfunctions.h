#ifndef _JULIA_CFUNCTIONS_H_
#define _JULIA_CFUNCTIONS_H_

/* Note, these declarations are function pointers. They can still be
 * called like regular functions without dereferencing.
 */
double (*julia_sind)(double x);
int (*mutual_fibonacci)(int n, int (*callback)(int n));
void (*add_element_number_int)(int *x, int n);
void (*add_element_number_float)(float *x, int n);

/* Loads the function pointers above. */
int load_julia_cfunctions(void);

#endif
