function setpath!(dict, keys, value)
    current = dict
    for i in 1:length(keys)-1
        key = keys[i]
        if !haskey(current, key) || !(current[key] isa Dict)
            current[key] = Dict()
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
