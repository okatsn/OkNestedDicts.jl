# OkNestedDicts
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://okatsn.github.io/OkNestedDicts.jl.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://okatsn.github.io/OkNestedDicts.jl.jl/dev/)
[![Build Status](https://github.com/okatsn/OkNestedDicts.jl.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/okatsn/OkNestedDicts.jl.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/okatsn/OkNestedDicts.jl.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/okatsn/OkNestedDicts.jl.jl)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://okatsn.github.io/OkNestedDicts.jl.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://okatsn.github.io/OkNestedDicts.jl.jl/dev)


A lightweight Julia package for easily manipulating nested dictionaries.

## Installation

This is a julia package created using `okatsn`'s preference, and this package is expected to be registered to [okatsn/OkRegistry](https://github.com/okatsn/OkRegistry) for CIs to work properly.

```julia
using Pkg
Pkg.add("OkNestedDicts")
```

## Usage

### Setting Values in Nested Dictionaries

Setting values in deeply nested dictionaries normally requires creating each level of the structure first:

```julia
# Traditional way (verbose)
metadata = Dict()
metadata["stats"] = Dict()
metadata["stats"]["accuracy"] = Dict()
metadata["stats"]["accuracy"]["value"] = 0.95
metadata["stats"]["accuracy"]["description"] = "Model accuracy"
```

With `OkNestedDicts`, you can do this in a single line:

```julia
using OkNestedDicts

# Simple path setting
metadata = Dict()
setpath!(metadata, ["stats", "accuracy", "value"], 0.95)

# Setting multiple paths
dict = Dict()
setpath!(dict, ["a", "b", "c"], 1)
setpath!(dict, ["a", "b", "d"], 2)
# Creates dict["a"]["b"]["c"] = 1 and dict["a"]["b"]["d"] = 2
```

### Setting Metrics

For metrics with values and descriptions, use the specialized `setmetric!` function:

```julia
metadata = Dict()

# Set metrics with value and description
setmetric!(metadata, ["stats", "accuracy"], 0.95, "Model accuracy")
setmetric!(metadata, ["stats", "f1_score"], 0.88, "F1 score on test set")

# Creates:
# metadata["stats"]["accuracy"]["value"] = 0.95
# metadata["stats"]["accuracy"]["description"] = "Model accuracy"
# metadata["stats"]["f1_score"]["value"] = 0.88
# metadata["stats"]["f1_score"]["description"] = "F1 score on test set"
```

## API Reference

### `setpath!(dict, keys, value) -> dict`

Sets a value in a nested dictionary at the path specified by `keys`.

- `dict`: The dictionary to modify
- `keys`: An array of keys representing the path to the value
- `value`: The value to set at the specified path

### `setmetric!(dict, keys, value, description="") -> dict`

Sets a metric with value and description at the specified path.

- `dict`: The dictionary to modify
- `keys`: An array of keys representing the path to the metric
- `value`: The metric value
- `description`: Optional description of the metric (defaults to "")

## License

MIT

This package is create on 2025-04-25.
