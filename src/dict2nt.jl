"""
Convert (Nested) Dictionary to NamedTuple.

```jldoctest
julia> d1 = Dict(:a => 1, :b => "hello", :c => 3.14);

julia> nt1 = dict2nt(d1);

julia> nt1 isa NamedTuple
true

julia> nt1.a == 1
true

julia> nt1.b == "hello"
true
```
"""
function dict2nt(d::Dict)
    return NamedTuple(Symbol(k) => (v isa Dict ? dict2nt(v) : v)
                      for (k, v) in pairs(d))
end
