"""
(Nested) Dictionary to NamedTuple.
"""
function dict2nt(d::Dict)
    return NamedTuple(Symbol(k) => (v isa Dict ? dict_to_namedtuple(v) : v)
                      for (k, v) in pairs(d))
end
