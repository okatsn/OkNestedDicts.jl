"""
Parse and `eval` any string values in a (nested) dictionary in the caller's scope.
Error will be raised if the string is not able to be parsed or evaluated.

The macro evaluates expressions in the scope where it's called, allowing access to
any modules, variables, and functions available in that scope.

# Examples
```julia
using Dates
d = Dict("date" => "DateTime(2022, 1, 1)", "calc" => "2 + 3")
result = @evalvalues d
# result["date"] will be DateTime(2022, 1, 1)
# result["calc"] will be 5
```
"""
macro evalvalues(obj)
    return esc(quote
        function _evalvalues_recursive(x::Dict)
            Dict(k => _evalvalues_recursive(v) for (k, v) in x)
        end

        function _evalvalues_recursive(x::String)
            eval(Meta.parse(x))
        end

        function _evalvalues_recursive(x)
            x  # fallback for any other type
        end

        _evalvalues_recursive($obj)
    end)
end
