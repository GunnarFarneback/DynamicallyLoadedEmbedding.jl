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

# Example of receiving an array of data. This function adds 1 to the
# first element, 2 to the second, and so on.
function add_element_number(x::Ptr, n::Integer)
    for i = 1:n
        element = unsafe_load(x, i)
        unsafe_store!(x, element + i, i)
    end
    return
end

# @cfunction can instantiate pointers to multiple specializations of
# the function for different argument types.
const add_element_number_int = @cfunction(add_element_number, Cvoid,
                                          (Ptr{Cint}, Cint))
const add_element_number_float = @cfunction(add_element_number, Cvoid,
                                            (Ptr{Cfloat}, Cint))
