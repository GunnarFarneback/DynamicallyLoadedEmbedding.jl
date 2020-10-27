# Dynamically Loaded Julia Embedding

This package serves two purposes.

* Make Julia embedding more accessible and easier to use.

* Provide a regression test (via
  [PkgEval](https://github.com/JuliaComputing/NewPkgEval.jl)) so that
  changes in new versions of Julia that break this form of embedding
  do not pass unnoticed.

With "Dynamically Loaded" it is understood that `libjulia` is not
linked into the embedding application but is loaded at runtime with
`dlopen`/`LoadLibrary`. This comes with both advantages and
disadvantages as discussed at some length in the
[background](docs/background.md) section. To summarize the main
advantages are:

* Not tied to a specific version of Julia.

* Julia is not needed in the build environment.

* The application can run without having Julia bundled or installed,
  for users who do not need the Julia functionality.

* All interaction is made via `cfunction`s - simpler interface than
  the "regular" embedding.

The main disadvantages are:

* More difficult setup of the embedding environment.

* All interaction is made via `cfunction`s - less powerful interface
  than the "regular" embedding.

The idea of this package is to take care of most of the difficulties
of this approach.

## Theoretical Background

The concepts and steps involved in a dynamically loaded embedding are
discussed in a separate [theory](docs/theory.md) section.

## Practical Use

The [c](c) directory contains a minimal example C implementation. Some
of the files can be reused and some need to be adapted to a specific
application. How to go about this is discussed in the separate
[practice](docs/practice.md) section.

## Licensing

This package is released under the [MIT license](LICENSE.md).

## Acknowledgements

This package is sponsored by
[ContextVision](http://www.contextvision.se), where the the same
approach is used to embed Julia in an in-house application.
