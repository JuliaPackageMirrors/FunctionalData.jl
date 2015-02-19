export at, setat!, fst, snd, third, last, @getfield
export part, trimmedpart, take, takelast, drop, droplast, partition, partsoflen
export getindex
export extract


#######################################
##  at

@compat @inline at{T,N}(a::NTuple{T,N},i) = a[i]
@compat @inline at(a::AbstractArray, ind::Tuple) = a[ind...]
@compat @inline at{T}(a::AbstractArray{T},i::AbstractArray) = 
    len(i) == 1 ? (size(i,1) == 1 ? at(a, i[1]) : a[subtoind(i,a)]) : error("index has len>1")
@compat @inline at{T}(a::AbstractArray{T,1},i::Number) = a[i]
#at{T,N}(a::AbstractArray{T,N},i) = slicedim(a,N,i)
@compat @inline at{T}(a::AbstractArray{T,2},i::Number) = col(a[:,i])
@compat @inline at{T}(a::AbstractArray{T,3},i::Number) = a[:,:,i]
@compat @inline at{T}(a::AbstractArray{T,4},i::Number) = a[:,:,:,i]
@compat @inline at{T}(a::AbstractArray{T,5},i::Number) = a[:,:,:,:,i]
@compat @inline at{T}(a::AbstractArray{T,6},i::Number) = a[:,:,:,:,:,i]
@compat @inline at{T}(a::AbstractArray{T,7},i::Number) = a[:,:,:,:,:,:,i]
@compat @inline at{T}(a::AbstractArray{T,8},i::Number) = a[:,:,:,:,:,:,:,i]
@compat @inline at(a,i) = a[i]


#######################################
##  setat!

@compat @inline setat!{T}(a::AbstractArray{T,1},i::Number,v) = (a[i] = v; a)
@compat @inline setat!{T}(a::AbstractArray{T,2},i::Number,v) = (a[:,i] = v; a)
@compat @inline setat!{T}(a::AbstractArray{T,3},i::Number,v) = (a[:,:,i] = v; a)
@compat @inline setat!{T}(a::AbstractArray{T,4},i::Number,v) = (a[:,:,:,i] = v; a)
@compat @inline setat!{T}(a::AbstractArray{T,5},i::Number,v) = (a[:,:,:,:,i] = v; a)
@compat @inline setat!{T}(a::AbstractArray{T,6},i::Number,v) = (a[:,:,:,:,:,i] = v; a)
@compat @inline setat!{T}(a::AbstractArray{T,7},i::Number,v) = (a[:,:,:,:,:,:,i] = v; a)
@compat @inline setat!{T}(a::AbstractArray{T,8},i::Number,v) = (a[:,:,:,:,:,:,:,i] = v; a)
@compat @inline setat!(a,i,v) = (a[i] = v; a)

@compat @inline fst(a) = at(a,1)
@compat @inline snd(a) = at(a,2)
@compat @inline third(a) = at(a,3)

import Base.last
@compat @inline last(a::Union(AbstractArray,String)) = at(a,len(a))
@compat @inline last(a::Union(AbstractArray,String), n) = trimmedpart(a,(-n+1:0)+len(a))

macro getfield(t,f)
    esc(:($t.$f))
end

#######################################
##  part

part(a, i::Real) = part(a,[i])
part{T}(a::Vector, i::AbstractArray{T,1}) = a[i]
part{T}(a::String, i::AbstractArray{T,1}) = string(a[i])
part{T}(a::NTuple{T},i::Int) = a[i]
part{T,T2,N}(a::Array{T2,N}, i::AbstractArray{T,1}) = slicedim(a,max(2,ndims(a)),i)
part{T1,T2}(a::AbstractArray{T1,1}, i::AbstractArray{T2,1}) = a[i]
part{T}(a::Dict, i::AbstractArray{T,1}) = Base.map(x->at(a,x),i)
part{T<:Real}(a,i::DenseArray{T,2}) = map(i, x->at(a,x))

trimmedpart(a, i::UnitRange) = part(a, max(1, minimum(i)):min(len(a),maximum(i)))

import Base.take
take(a,n) = part(a,1:min(n,len(a)))
takelast(a,n) = part(a,max(1,len(a)-n+1):len(a))

drop(a,i) = part(a,i+1:len(a))

droplast(a) = part(a,1:max(1,len(a)-1))
droplast(a,i) = part(a,1:max(1,len(a)-i))

function partition(a,n) 
    r = cell(n)
    n2 = min(n, len(a))
    s = len(a)
    stepsize = s/n2
    pos = stepsize
    ndone = 0
    for i = 1:n2
        r[i] = part(a, ndone + 1 : min(ceil(Integer, pos+stepsize-1), s))
        pos += stepsize
        ndone += length(r[i])
    end
    for i = n2+1:n
        r[i] = cell(0)
    end
    r
end

function partsoflen(a,n) 
    s = size(a,ndims(a))

    indices = Any[Base.map(x->1:x, size(a))...]
    [part(a, indices[1:end-1]...,ceil(i):floor(min(s,i+n-1))) for i in 1:n:s]
end

extract(a, x) = extract(a, x, nothing)
function extract(a, x, default)
  r = cell(size(a))
  if isa(a[1], Dict)
    for i = 1:length(r)
      r[i] = haskey(a[i], x) ? a[i][x] : default
    end
    return r
  end
  assert(isa(x,Symbol))
  for i = 1:length(r)
      r[i] = @getfield(a[i],$x)
  end
  return r
end




