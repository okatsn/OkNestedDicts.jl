"""
Parse and `eval` any string values in a (nested) dictionary.
Error will be raised if the string is not able to be parsed or evaluated.
"""
evalvalues(obj::Dict) = Dict(k => evalvalues(v) for (k, v) in obj)
evalvalues(obj::String) = eval(Meta.parse(obj))
evalvalues(obj) = obj  # fallback for any other type
