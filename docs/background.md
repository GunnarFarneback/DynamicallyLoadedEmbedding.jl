## Dynamic Loading of `libjulia`

The method of embedding shown in the Julia documentation, `Embedding
Julia` section, requires that the embedding program is linked with
`libjulia`. As a consequence `libjulia` and the rest of the Julia
runtime must be shipped with the embedding program, alternatively the
user of the program is required to have a matching Julia installed, in
order to use the program at all.

In some situations, e.g. if you have a large application where Julia
is only an optional backend or plugin, this can be
problematic. Requiring users that don't need the Julia functionality
to have Julia (of the right version) installed is rather user
unfriendly, and the Julia runtime is large enough that bundling it
will likely have noticeable effects on the application size.

If this is the case, an alternative strategy is to dynamically load
`libjulia` with `dlopen` (`LoadLibrary` in Windows). This means that
`libjulia` is loaded at runtime when it is needed, and those who do
not need Julia functionality also do not need to have Julia installed,
or bundled.

This approach does not come for free, however. It needs a certain
amount of overhead related to the loading, and only a subset of the
functions in `julia.h` can conveniently be used. Specifically anything
involving C macros is unavailable, which severely limits the
possibilities to manage memory and the use of everything that depends
on correct memory management. This is not quite as crippling as it may
sound, however. The key is to perform all communication with the Julia
code through `cfunction`s and pass data using only types from C.
