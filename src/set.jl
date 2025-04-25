"""
    setpath!(dict, keys, value) -> dict

Set a value in a nested dictionary at the path specified by `keys`.

Creates the necessary nested dictionary structure if it doesn't exist.
Throws an `ArgumentError` if a non-dictionary value is encountered along the path.

# Arguments
- `dict`: The dictionary to modify
- `keys`: An array of keys representing the path to the value
- `value`: The value to set at the specified path

# Examples
```julia
dict = Dict()
setpath!(dict, ["a", "b", "c"], 1)  # creates dict["a"]["b"]["c"] = 1

# With existing structure
dict = Dict("a" => Dict())
setpath!(dict, ["a", "b"], 2)       # creates dict["a"]["b"] = 2
```
"""
function setpath!(dict, keys, value)
    current = dict
    # Consider the dictionary as a tree structure, i = 1 is the root node,
    # and the `end` key is the leaf node to assign value.
    for i in 1:length(keys)-1 # iterate over the nodes along the path the one before the leaf node.
        key = keys[i]
        if !haskey(current, key) # If the node does not exist, create one.
            current[key] = Dict()
        elseif !(current[key] isa Dict) # Along the path to the leaf node, you should not encounter any non-Dict value.
            throw(ArgumentError("Cannot create nested dictionary: key '$(key)' already exists with a non-Dict value $(current[key])"))
        else # if the key exist and is a dictionary
            # pass
        end

        current = current[key]
    end
    current[keys[end]] = value
    return dict
end

"""
    setmetric!(dict, keys, value, description="") -> dict

Set a metric with value and description at the specified path in a nested dictionary.

Creates a dictionary with "value" and "description" keys and sets it at the specified path.

# Arguments
- `dict`: The dictionary to modify
- `keys`: An array of keys representing the path to the metric
- `value`: The metric value
- `description`: Optional description of the metric (defaults to "")

# Examples
```julia
metadata = Dict()
setmetric!(metadata, ["quality", "accuracy"], 0.95, "Model accuracy")
# Creates metadata["quality"]["accuracy"] = Dict("value" => 0.95, "description" => "Model accuracy")
```
"""
function setmetric!(dict, keys, value, description="")
    # Create the metric Dict
    metric_dict = Dict("value" => value, "description" => description)
    # Add it at the specified path
    setpath!(dict, keys, metric_dict)
    return dict
end
