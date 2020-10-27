## Overview

To use a dynamically loaded `libjulia` involves a number of setup
steps.

* Open `libjulia` with `dlopen`/`LoadLibrary`.
* Obtain function pointers to the functions needed from `libjulia`.
* Initialize Julia.
* Load the Julia code that is going to be used and create `cfunction`
  pointers to the functions the embedding code will interact with.
* Retrieve the `cfunction` pointers from the embedding code.

Each of these steps will be discussed in more detail but to see the
full picture, look at example implementation in the [c][../c]
directory. That code also includes error handling, which is omitted
from this presentation for brevity.

## Load `libjulia`

### Linux

Dynamic loading of `libjulia` is done with `dlopen`.
```
#include <dlfcn.h>
void *libjulia = dlopen("libjulia.so");
```
In order for the application to be able to find `libjulia.so`, it
needs to be in a directory listed in `LD_LIBRARY_PATH`. Alternatively
it can be in the `rpath` built into the executable or `dlopen` is
given an absolute path. In the latter case the embedding program can
determine the path from additional information, e.g. querying the
Julia binary (assuming it is in `PATH`) or relying on some environment
variable to point to the location of `libjulia`.

### Mac

Same as Linux with the exception that the library is called
`libjulia.dylib` instead of `libjulia.so`.

### Windows

Dynamic loading of `libjulia` is done with `LoadLibrary`.

```
#include <windows.h>
HMODULE libjulia = LoadLibrary("libjulia.dll");
```

In order for the application to be able to find `libjulia.dll`, it
must either be in the same directory as the executable, or in the
`PATH` environment variable.

## Retrieve Function Pointers from `libjulia`

### Linux and Mac

Function pointers are retrieved from `libjulia` using `dlsym`.
```
void (*jl_init)(void) = dlsym(libjulia, "jl_init");
```
The `jl_init` function can now be called directly through the function pointer,
```
jl_init();
```

Is is not necessary to first dereference the function pointer,
although that works as well. Effectively this means that function
pointers are masquerading as regular functions.

This loading of function pointers has to be done for each and every
function from `libjulia` that is needed, so it is advantageous to keep
the list as short as possible.

Some functions have arguments or return value of a Julia type,
e.g. `jl_value_t`. These types can be obtained by `#include "julia.h"`
but that would interfere with the masquerading trick and is not really
necessary. It is sufficient to declare them locally without the
definition of what is inside the `struct`s.
```
typedef struct _jl_value_t jl_value_t;
```
Not only functions can be found in `libjulia`, but also global
variables, e.g. the useful `jl_main_module`. These can also be
retrieved by `dlsym`.
```
jl_module_t **p_jl_main_module = dlsym(libjulia, "jl_main_module");
#define jl_main_module (*p_jl_main_module)
```
In this case the masquerading must be done indirectly.

### Windows

The only difference from Linux is that `dlsym` is replaced by
`GetProcAddress`.

### Renaming of `jl_init`

If Julia has been compiled with threading enabled, `jl_init` goes
under the name of `jl_init__threading`. The easiest way to find out is
to ask `dlsym` to resolve the symbols.
```
void (*p_jl_init)(void) = dlsym(libjulia, "jl_init");
if (!p_jl_init)
    (*p_jl_init)(void) = dlsym(libjulia, "jl_init__threading");
#define jl_init (*p_jl_init)
```
This is also the case for `jl_init_with_image`.

## Initialize Julia

Initialization of Julia is the same as without dynamic loading of
`libjulia`. Normally it is sufficient to just do
```
jl_init();
```

If you want to start julia with a custom system image, you need to use
```
jl_init_with_image(julia_bindir, julia_system_image_path);
```

This requires that you can locate `julia_bindir`, the directory where
the julia binary lives. Note: in theory `julia_bindir` can be set to
`NULL` but that does not work with embedding.

## Creating and Retrieving `cfunction` Pointers

The interaction between the embedding code and the Julia code is most
easily done by calling specific methods of Julia functions as
`cfunction`s and using C types for the data passed back and forth.
```
jl_eval_string("const julia_sind = @cfunction(sind, Cdouble, (Cdouble,))");
double (*p_julia_sind)(double) = jl_unbox_voidpointer(
    jl_get_global(jl_main_module, jl_symbol("julia_sind")));
printf("%f\n", (*p_julia_sind)(30.0));
```
The creation of the needed `cfunction` pointers, as well as loading of
the Julia code, is most convenient to do all at once in a Julia file
and including it in `Main`.
```
jl_eval_string("include(\"setup.jl\")");
```
Retrieval of the `cfunction` pointers must be done one by one but the
lengthy invocation can of course be packaged into a helper
function.
