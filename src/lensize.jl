export len, siz, siz3

len(a) = length(a)
len{T,N}(a::AbstractArray{T,N}) = size(a,N)

siz(a::Number) = ones(Int, 2, 1)

function siz(a::Tuple)
    r = ones(Int, 2, 1)
    r[1] = 1
    r[2] = length(a)
    r
end

function siz(a::Union(UnitRange, Char, ASCIIString, SubString{ASCIIString}))
    r = ones(Int, 2,1)
    r[2] = length(a)
    r
end


function siz{T,N}(a::AbstractArray{T,N})
    r = ones(Int, max(2,N), 1)
    for i = 1:N
        r[i] = size(a,i)
    end
    r
end

function siz3{T,N}(a::Array{T,N})
    if N > 3
        error("siz3 can only be used for arrays with ndims <= 3")
    end
    r = ones(Int, 3, 1)
    for i = 1:N
        r[i] = size(a,i)
    end
    r
end
siz3(a) = siz(a)