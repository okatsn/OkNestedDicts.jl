evalvalues(obj::Dict) = Dict(k => evalvalues(v) for (k, v) in obj)
evalvalues(obj::String) = eval(Meta.parse(obj))
evalvalues(obj) = obj  # fallback for any other type
