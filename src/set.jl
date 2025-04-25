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

function setmetric!(dict, keys, value, description)
    # Create the metric Dict
    metric_dict = Dict("value" => value, "description" => description)
    # Add it at the specified path
    setpath!(dict, keys, metric_dict)
    return dict
end
