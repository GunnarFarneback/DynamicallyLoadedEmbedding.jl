using DynamicallyLoadedEmbedding
using Test
using Libdl
# Piggyback on PackageCompiler internals. May have to replicate that
# code if the internals change.
using PackageCompiler: get_compiler, run_with_env, default_sysimg_path

# Compile the C code.
srcdir = joinpath(dirname(@__DIR__), "c")
destdir = mktempdir()
compiler = get_compiler()
if Sys.iswindows()
    binary_path = "$(destdir)/julia_embedding.exe"
    cmd = `$(compiler) $(srcdir)/julia_embedding.c $(srcdir)/julia_cfunctions.c $(srcdir)/main.c -o $(binary_path)`
else
    binary_path = "$(destdir)/julia_embedding"
    cmd = `$(compiler) $(srcdir)/julia_embedding.c $(srcdir)/julia_cfunctions.c $(srcdir)/main.c -ldl -o $(binary_path)`
end
run_with_env(cmd, compiler)
if !isfile(binary_path)
    error("Failed to compile binary.")
end

if Sys.iswindows()
    # Place `julia` in PATH. It is assumed that this makes `libjulia`
    # also available from PATH.
    ENV["PATH"] = string(Sys.BINDIR, ";", ENV["PATH"])
else
    # Make `libjulia` available in LD_LIBRARY_PATH.
    libdir = dirname(abspath(Libdl.dlpath("libjulia")))
    ENV["LD_LIBRARY_PATH"] = string(libdir, ":", get(ENV, "LD_LIBRARY_PATH", ""))
end

cfunctions_path = abspath(dirname(@__DIR__), "src", "julia_cfunctions.jl")

# `VERSION` is usually not the same as this for nightly builds.
# TODO: Find out whether there's some more convenient way to get
#       exactly the same string as this `ccall`.
version_string = unsafe_string(ccall(:jl_ver_string, Ptr{Cchar}, ()))
expected_stdout =
    """
    Julia version $(version_string)
    0.5
    fibonacci(10) = 55
    xi = 2 3 4 4
    xf = 1.0 2.5 4.0
    """

expected_stderr =
    """
    Exception test: MethodError: no method matching this_function_has_no_methods()
    """

@testset "without sysimage" begin
    out = Pipe()
    err = Pipe()
    p = run(pipeline(`$(binary_path) "" $(cfunctions_path)`,
                     stdin=devnull, stdout=out, stderr=err))
    close(out.in)
    close(err.in)
    @test replace(read(out, String), "\r\n" => "\n") == expected_stdout
    @test replace(read(err, String), "\r\n" => "\n") == expected_stderr
end

@testset "with sysimage" begin
    out = Pipe()
    err = Pipe()
    # Use the default system image to test the custom system image
    # code paths.
    p = run(pipeline(`$(binary_path) $(default_sysimg_path()) $(cfunctions_path)`,
                     stdin=devnull, stdout=out, stderr=err))
    close(out.in)
    close(err.in)
    @test replace(read(out, String), "\r\n" => "\n") == expected_stdout
    @test replace(read(err, String), "\r\n" => "\n") == expected_stderr
end
