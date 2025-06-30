using Test
using OkNestedDicts

@testset "evalvalues tests" begin

    @testset "String evaluation" begin
        # Basic arithmetic expressions
        @test evalvalues("1 + 2") == 3
        @test evalvalues("2 * 3") == 6
        @test evalvalues("10 / 2") == 5.0
        @test evalvalues("2^3") == 8
        @test evalvalues("5 - 3") == 2

        # Mathematical functions
        @test evalvalues("sin(0)") == 0.0
        @test evalvalues("cos(0)") == 1.0
        @test evalvalues("sqrt(4)") == 2.0
        @test evalvalues("abs(-5)") == 5

        # Boolean expressions
        @test evalvalues("true") == true
        @test evalvalues("false") == false
        @test evalvalues("1 > 0") == true
        @test evalvalues("2 < 1") == false
        @test evalvalues("true && false") == false
        @test evalvalues("true || false") == true

        # String literals
        @test evalvalues("\"hello\"") == "hello"
        @test evalvalues("'a'") == 'a'

        # Array/collection expressions
        @test evalvalues("[1, 2, 3]") == [1, 2, 3]
        @test evalvalues("(1, 2, 3)") == (1, 2, 3)
        @test evalvalues("1:5") == 1:5

        # Variable assignment and usage (within the eval context)
        @test evalvalues("x = 5; x + 1") == 6

        # Complex expressions
        @test evalvalues("2 * (3 + 4)") == 14
        @test evalvalues("length([1, 2, 3, 4])") == 4

        # Mathematical constants
        @test evalvalues("π") ≈ π
        @test evalvalues("ℯ") ≈ ℯ
    end

    @testset "Dictionary evaluation - flat" begin
        # Simple flat dictionary
        dict1 = Dict("a" => "1 + 1", "b" => "2 * 3", "c" => "sqrt(16)")
        result1 = evalvalues(dict1)
        @test result1["a"] == 2
        @test result1["b"] == 6
        @test result1["c"] == 4.0

        # Mixed types in dictionary
        dict2 = Dict("math" => "5 + 5", "bool" => "true", "str" => "\"test\"")
        result2 = evalvalues(dict2)
        @test result2["math"] == 10
        @test result2["bool"] == true
        @test result2["str"] == "test"

        # Dictionary with non-string values (should remain unchanged)
        dict3 = Dict("a" => "1 + 1", "b" => 42, "c" => true, "d" => [1, 2, 3])
        result3 = evalvalues(dict3)
        @test result3["a"] == 2
        @test result3["b"] == 42
        @test result3["c"] == true
        @test result3["d"] == [1, 2, 3]
    end

    @testset "Dictionary evaluation - nested" begin
        # Nested dictionary
        nested_dict = Dict(
            "level1" => Dict(
                "a" => "2 + 2",
                "b" => "3 * 3",
                "level2" => Dict(
                    "x" => "sin(π/2)",
                    "y" => "10 / 2"
                )
            ),
            "simple" => "1 + 1"
        )

        result = evalvalues(nested_dict)
        @test result["level1"]["a"] == 4
        @test result["level1"]["b"] == 9
        @test result["level1"]["level2"]["x"] ≈ 1.0
        @test result["level1"]["level2"]["y"] == 5.0
        @test result["simple"] == 2

        # Deep nesting
        deep_dict = Dict(
            "a" => Dict(
                "b" => Dict(
                    "c" => Dict(
                        "d" => "2^4"
                    )
                )
            )
        )

        deep_result = evalvalues(deep_dict)
        @test deep_result["a"]["b"]["c"]["d"] == 16
    end

    @testset "Non-dictionary types (fallback)" begin
        # Numbers should remain unchanged
        @test evalvalues(42) == 42
        @test evalvalues(3.14) == 3.14
        @test evalvalues(-5) == -5

        # Booleans should remain unchanged
        @test evalvalues(true) == true
        @test evalvalues(false) == false

        # Arrays should remain unchanged
        @test evalvalues([1, 2, 3]) == [1, 2, 3]
        @test evalvalues(["a", "b", "c"]) == ["a", "b", "c"]

        # Tuples should remain unchanged
        @test evalvalues((1, 2, 3)) == (1, 2, 3)
        @test evalvalues(("a", "b")) == ("a", "b")

        # Nothing and missing
        @test evalvalues(nothing) === nothing
        @test evalvalues(missing) === missing

        # Symbols
        @test evalvalues(:symbol) == :symbol
    end

    @testset "Error handling" begin
        # Invalid syntax
        @test_throws Exception evalvalues("1 +")
        @test_throws Exception evalvalues("invalid syntax +++")
        @test_throws Exception evalvalues("1 + * 2")

        # Undefined variables
        @test_throws Exception evalvalues("undefined_variable")
        @test_throws Exception evalvalues("x + y")  # unless x and y are defined

        # Invalid function calls
        @test_throws Exception evalvalues("nonexistent_function()")

        # Dictionary with invalid string expressions
        invalid_dict = Dict("good" => "1 + 1", "bad" => "invalid syntax")
        @test_throws Exception evalvalues(invalid_dict)
    end

    @testset "Edge cases" begin
        # Empty dictionary
        @test evalvalues(Dict()) == Dict()        # Empty string
        @test evalvalues("") === nothing  # Empty string parses to nothing

        # Whitespace-only string
        @test evalvalues("   ") === nothing  # Whitespace-only parses to nothing

        # Dictionary with empty values
        dict_with_empty = Dict("a" => "1", "b" => 2)
        result = evalvalues(dict_with_empty)
        @test result["a"] == 1
        @test result["b"] == 2

        # Very nested expression
        complex_expr = "((2 + 3) * (4 - 1)) / (sqrt(9) + sin(0))"
        @test evalvalues(complex_expr) == 15.0 / 3.0

        # Dictionary with symbol keys
        symbol_key_dict = Dict(:a => "1 + 1", :b => "2 * 2")
        symbol_result = evalvalues(symbol_key_dict)
        @test symbol_result[:a] == 2
        @test symbol_result[:b] == 4

        # Mixed key types
        mixed_key_dict = Dict("string_key" => "1 + 1", :symbol_key => "2 + 2", 1 => "3 + 3")
        mixed_result = evalvalues(mixed_key_dict)
        @test mixed_result["string_key"] == 2
        @test mixed_result[:symbol_key] == 4
        @test mixed_result[1] == 6
    end

    @testset "Type preservation" begin
        # Ensure the result types are correct
        type_dict = Dict(
            "int" => "5",
            "float" => "5.0",
            "bool_true" => "true",
            "bool_false" => "false",
            "string" => "\"hello\"",
            "array" => "[1, 2, 3]",
            "tuple" => "(1, 2)",
            "range" => "1:5"
        )

        result = evalvalues(type_dict)
        @test isa(result["int"], Int)
        @test isa(result["float"], Float64)
        @test isa(result["bool_true"], Bool)
        @test isa(result["bool_false"], Bool)
        @test isa(result["string"], String)
        @test isa(result["array"], Vector)
        @test isa(result["tuple"], Tuple)
        @test isa(result["range"], UnitRange)
    end

    @testset "Complex data structures" begin
        # Dictionary containing arrays with string expressions
        complex_dict = Dict(
            "data" => Dict(
                "values" => "collect(1:5)",
                "sum" => "sum([1, 2, 3, 4, 5])",
                "nested_array" => "[[1, 2], [3, 4]]"
            ),
            "metadata" => Dict(
                "count" => "length([1, 2, 3])",
                "name" => "\"dataset\""
            )
        )

        result = evalvalues(complex_dict)
        @test result["data"]["values"] == [1, 2, 3, 4, 5]
        @test result["data"]["sum"] == 15
        @test result["data"]["nested_array"] == [[1, 2], [3, 4]]
        @test result["metadata"]["count"] == 3
        @test result["metadata"]["name"] == "dataset"
    end
end
