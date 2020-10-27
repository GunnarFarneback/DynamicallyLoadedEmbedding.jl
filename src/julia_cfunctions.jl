const julia_sind = @cfunction(sind, Cdouble, (Cdouble,))

# Mutually recursive fibonacci implementation which bounces back and
# forth between Julia and C.
function mutual_fibonacci(n::Cint, callback::Ptr{Cvoid})::Cint
    if n <= 1
        return n
    end

    return ccall(callback, Cint, (Cint,), n - 1) +
           ccall(callback, Cint, (Cint,), n - 2)
end

const mutual_fibonacci_ptr = @cfunction(mutual_fibonacci, Cint, (Cint, Ptr{Cvoid}))
