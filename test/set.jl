using OkNestedDicts
using Test

@testset "OkNestedDicts.setpath!" begin
    # Basic functionality
    dict = Dict()
    setpath!(dict, ["a", "b", "c"], 1)
    @test dict["a"]["b"]["c"] == 1

    # With existing keys
    dict = Dict("a" => Dict("b" => Dict()))
    setpath!(dict, ["a", "b", "c"], 2)
    @test dict["a"]["b"]["c"] == 2

    # Overwriting non-Dict values with Dict
    dict = Dict("a" => Dict("b" => 5))
    setpath!(dict, ["a", "b"], 3)
    @test dict["a"]["b"] == 3

    # Test setting values to the same node with branching.
    dict = Dict()
    setpath!(dict, ["a", "b", "c", "d"], 3)
    setpath!(dict, ["a", "b", "c2"], 2.5)

    @test dict["a"]["b"]["c"]["d"] == 3
    @test dict["a"]["b"]["c2"] == 2.5
    setpath!(dict, ["a", "b", "c", "d"], 3.4)
    # test promotion
    @test dict["a"]["b"]["c"]["d"] == 3.4

    # Edge case: single key path
    dict = Dict()
    setpath!(dict, ["a"], 4)
    @test dict["a"] == 4

    # Test return value (should return the original dict)
    dict = Dict()
    result = setpath!(dict, ["a"], 5)
    @test result === dict
end

@testset "OkNestedDicts.setmetric!" begin
    # Basic functionality
    dict = Dict()
    setmetric!(dict, ["a", "b"], 0.5, "Test metric")
    @test dict["a"]["b"]["value"] == 0.5
    @test dict["a"]["b"]["description"] == "Test metric"

    # With existing structure
    dict = Dict("stats" => Dict())
    setmetric!(dict, ["stats", "accuracy"], 0.95, "Model accuracy")
    @test dict["stats"]["accuracy"]["value"] == 0.95
    @test dict["stats"]["accuracy"]["description"] == "Model accuracy"

    # Test the specific example from docs
    metadata = Dict()
    nan_ratio = 0.1
    outlier_ratio = 0.05

    # Set complete metrics with both value and description
    setmetric!(metadata, ["statind_long", "nan_ratio"], nan_ratio, "Ratio of NaN values in the dataset")
    setmetric!(metadata, ["statind_long", "outlier_ratio"], outlier_ratio, "Gross ratio of data identified as outlier")

    # Verify the structure matches what we'd expect
    @test metadata["statind_long"]["nan_ratio"]["value"] == nan_ratio
    @test metadata["statind_long"]["nan_ratio"]["description"] == "Ratio of NaN values in the dataset"
    @test metadata["statind_long"]["outlier_ratio"]["value"] == outlier_ratio
    @test metadata["statind_long"]["outlier_ratio"]["description"] == "Gross ratio of data identified as outlier"

    # Verify we can update individual fields with setpath!
    setpath!(metadata, ["statind_long", "nan_ratio", "description"], "Updated description")
    @test metadata["statind_long"]["nan_ratio"]["description"] == "Updated description"

    # Test return value (should return the original dict)
    dict = Dict()
    result = setmetric!(dict, ["a"], 1, "test")
    @test result === dict
end
