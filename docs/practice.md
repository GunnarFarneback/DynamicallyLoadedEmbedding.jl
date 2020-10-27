## Practice

This section explains how to use dynamically loaded embedding in your
own C application. The same techniques can be used from other
languages but this documentation and example focuses on C.

### Prerequisites

At least a basic familiarity with Julia `ccall` and `cfunction` is
assumed, as well as a sufficient proficiency in C.

To run the example on Windows, the `julia` executable needs to be in
the `PATH` environment variable. On other platforms, `libjulia` needs
to be in `LD_LIBRARY_PATH`. In all cases it is assumed that Julia is
either built from source or installed from the official binaries or
installation packages.

### File Layout

The implementation in this package consists of the following files:

* [`c/julia_embedding.c`](../c/julia_embedding.c) - supporting infrastructure
* [`c/julia_embedding.h`](../c/julia_embedding.h) - public API to the infrastructure
* [`c/julia_cfunctions.c`](../c/julia_cfunctions.c) - loading of pointers to Julia functions
* [`c/julia_cfunctions.h`](../c/julia_cfunctions.h) - public API to the Julia functions
* [`c/main.c`](../c/main.c) - example application
* [`src/julia_cfunctions.jl`](../src/julia_cfunctions.jl) - Julia implementation of exposed functions

### Building and Running the Example Application

To build on Windows:

`gcc julia_embedding.c julia_cfunctions.c main.c -o embedding_example.exe`

or correspondingly with another compiler than `gcc`.

To build elsewhere:

`gcc julia_embedding.c julia_cfunctions.c main.c -ldl -o embedding_example`

or correspondingly with another compiler than `gcc`.

To run:
`./embedding_example [system_image_path] [julia_cfunctions_path]`

Both arguments are optional. The first argument points to a system
image. If missing or empty the default system image is used. The
second argument points to the Julia implementation of the functions to
be called from C and defaults to `../src/julia_cfunctions.jl`.

### Customizing the Example for Your Own Application

The `julia_embedding.c` and `julia_embedding.h` infrastructure can
likely be mostly used without change. The main exception is if your
application wants error messages to go somewhere other than to
`stderr`.

`julia_cfunctions.jl` naturally needs to be replaced with Julia
implementations of the functions your application wants to call. This
may also include project activation, project instantiation, and
loading of packages. It must store `cfunction` pointers to all exposed
functions in the `Main` module.

In `julia_cfunctions.c`, the `load_julia_cfunctions` function must be
rewritten to load `cpointers` to your Julia functions.
`julia_cfunctions.h` needs to be edited correspondingly.

`main.c` needs to be replaced by code within your application.

### Public API

The infrastructure support in `julia_embedding.c` exposes the
following functions:

---

    const char *julia_preinitialize();

Optional call to load `libjulia` and selected functions from the
library. It returns the version string of `libjulia`. This can for
example be used to select a matching system image (which are not
portable between Julia versions).

---

    int julia_initialize(const char *julia_loader_filename,
                         const char *julia_system_image_path);

Loads `libjulia` (if not already done by the previous function) and
initializes the Julia runtime. Then `include`s the file which creates
the Julia functions (`julia_cfunctions.jl` in the example). Optionally
initializes the runtime with a custom system image unless
`julia_system_image_path` is a NULL pointer or points to an empty
string.

Returns 0 on failure and 1 on success.

---

    int julia_eval_string(const char *command, const char *error_message);

This function can be called if there is a need to run more Julia code
at the top level, in addition to the `include` done from
`julia_initialize`. This is a wrapper around `jl_eval_string`, which
catches and reports errors. 

Returns 0 on failure and 1 on success.

---

    void *get_cfunction_pointer(const char *name);

This is used from the `load_julia_cfunctions` function, which in turn
should be called after `julia_initialize` to finish the setup.

---

    int julia_exit(int);

Clean up Julia. The argument is the program return code, which is
also returned by the function.
