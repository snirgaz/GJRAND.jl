module GJRand

export GJRandRNG

using Random: Random, AbstractRNG, Sampler, SamplerType, RandomDevice

import Random: rand, seed!

mutable struct GJRandRNG <: AbstractRNG
    a::UInt64
    b::UInt64
    c::UInt64
    d::UInt64
    GJRandRNG(seed::UInt64) = seed!(new(), seed)
    GJRandRNG() = GJRandRNG(rand(RandomDevice(),UInt64))
end

function seed!(gjrand::GJRandRNG,seed::UInt64)
    gjrand.a=seed
    gjrand.b=UInt64(0)
    gjrand.c=UInt64(2000001)
    gjrand.d=UInt64(0)
    for j=1:14
        advance!(gjrand)
    end
    gjrand
end
function rotate(x::UInt64,k::UInt64)
        return ((x << k) | (x >> (64 - k)))
end


function advance!(gjrand::GJRandRNG)
        gjrand.b += gjrand.c;
        gjrand.a =  rotate(gjrand.a, UInt64(32))
        gjrand.c ⊻= gjrand.b;
        gjrand.d += UInt64(0x55aa96a5);
        gjrand.a += gjrand.b;
        gjrand.c =  rotate(gjrand.c, UInt64(23))
        gjrand.b ⊻= gjrand.a;
        gjrand.a += gjrand.c;
        gjrand.b =  rotate(gjrand.b, UInt64(19))
        gjrand.c += gjrand.a;
        gjrand.b += gjrand.d;
    end


function rand(gjrand::GJRandRNG, ::SamplerType{UInt64})
    advance!(gjrand);
    return UInt64(gjrand.a);
end
for T = [Bool, Base.BitInteger64_types...]
    T === UInt64 && continue
    @eval rand(rng::GJRandRNG, ::SamplerType{$T}) = rand(rng, UInt64) % $T
end
Random.rng_native_52(::GJRandRNG) = UInt64


end
