using Test
using OkNestedDicts
using Dates

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

    @testset "DateTime and DatePeriod evaluation" begin
        using Dates
        # Basic DateTime construction
        @test evalvalues("DateTime(2022, 1, 1)") == DateTime(2022, 1, 1)
        @test evalvalues("DateTime(2023, 12, 25, 14, 30, 0)") == DateTime(2023, 12, 25, 14, 30, 0)
        @test evalvalues("Date(2022, 6, 15)") == Date(2022, 6, 15)
        @test evalvalues("Time(10, 30, 45)") == Time(10, 30, 45)

        # DateTime parsing from strings
        @test evalvalues("DateTime(\"2022-01-01\")") == DateTime("2022-01-01")
        @test evalvalues("Date(\"2022-06-15\")") == Date("2022-06-15")
        @test evalvalues("Time(\"10:30:45\")") == Time("10:30:45")

        # Period types
        @test evalvalues("Month(1)") == Month(1)
        @test evalvalues("Day(7)") == Day(7)
        @test evalvalues("Hour(24)") == Hour(24)
        @test evalvalues("Minute(60)") == Minute(60)
        @test evalvalues("Second(3600)") == Second(3600)
        @test evalvalues("Year(2022)") == Year(2022)
        @test evalvalues("Week(4)") == Week(4)
        @test evalvalues("Millisecond(1000)") == Millisecond(1000)

        # CompoundPeriod
        @test evalvalues("Month(2) + Day(15)") == Month(2) + Day(15)
        @test evalvalues("Year(1) + Month(6) + Day(15)") == Year(1) + Month(6) + Day(15)
        @test evalvalues("Hour(2) + Minute(30) + Second(45)") == Hour(2) + Minute(30) + Second(45)

        # DateTime arithmetic
        base_date = DateTime(2022, 1, 1)
        @test evalvalues("DateTime(2022, 1, 1) + Month(1)") == base_date + Month(1)
        @test evalvalues("DateTime(2022, 1, 1) + Day(30)") == base_date + Day(30)
        @test evalvalues("DateTime(2022, 1, 1) + Hour(12)") == base_date + Hour(12)

        # Dictionary with DateTime expressions
        datetime_dict = Dict(
            "start_date" => "DateTime(2022, 1, 1)",
            "end_date" => "DateTime(2022, 12, 31)",
            "duration" => "Month(6)",
            "weekly_period" => "Week(2)",
            "parsed_date" => "Date(\"2022-06-15\")"
        )

        result = evalvalues(datetime_dict)
        @test result["start_date"] == DateTime(2022, 1, 1)
        @test result["end_date"] == DateTime(2022, 12, 31)
        @test result["duration"] == Month(6)
        @test result["weekly_period"] == Week(2)
        @test result["parsed_date"] == Date(2022, 6, 15)

        # Nested dictionary with DateTime calculations
        nested_datetime_dict = Dict(
            "project" => Dict(
                "start" => "DateTime(2022, 1, 1)",
                "milestone1" => "DateTime(2022, 1, 1) + Month(3)",
                "milestone2" => "DateTime(2022, 1, 1) + Month(6)",
                "duration" => "Month(12)"
            ),
            "periods" => Dict(
                "quarter" => "Month(3)",
                "semester" => "Month(6)",
                "year" => "Year(1)"
            )
        )

        nested_result = evalvalues(nested_datetime_dict)
        @test nested_result["project"]["start"] == DateTime(2022, 1, 1)
        @test nested_result["project"]["milestone1"] == DateTime(2022, 4, 1)
        @test nested_result["project"]["milestone2"] == DateTime(2022, 7, 1)
        @test nested_result["project"]["duration"] == Month(12)
        @test nested_result["periods"]["quarter"] == Month(3)
        @test nested_result["periods"]["semester"] == Month(6)
        @test nested_result["periods"]["year"] == Year(1)

        # Date functions and operations
        @test evalvalues("now()") isa DateTime
        @test evalvalues("today()") isa Date
        @test evalvalues("Dates.dayofweek(Date(2022, 1, 1))") == 6  # Saturday
        @test evalvalues("Dates.month(Date(2022, 6, 15))") == 6
        @test evalvalues("Dates.year(DateTime(2022, 1, 1))") == 2022

        # Date ranges
        @test evalvalues("Date(2022, 1, 1):Day(1):Date(2022, 1, 3)") == Date(2022, 1, 1):Day(1):Date(2022, 1, 3)
        @test evalvalues("DateTime(2022, 1, 1, 0):Hour(6):DateTime(2022, 1, 1, 12)") == DateTime(2022, 1, 1, 0):Hour(6):DateTime(2022, 1, 1, 12)

        # Complex DateTime expressions
        @test evalvalues("DateTime(2022, 1, 1) + Month(6) + Day(15) + Hour(12)") == DateTime(2022, 7, 16, 12)
        @test evalvalues("Date(2022, 12, 31) - Month(11)") == Date(2022, 1, 31)

        # TimeZone-aware operations (if TimeZones.jl is available, but let's test basic functionality)
        @test evalvalues("DateTime(2022, 1, 1, 12, 0, 0)") == DateTime(2022, 1, 1, 12, 0, 0)

        # Type checking for DateTime results
        datetime_type_dict = Dict(
            "datetime" => "DateTime(2022, 1, 1)",
            "date" => "Date(2022, 1, 1)",
            "time" => "Time(12, 30)",
            "period" => "Month(1)",
            "compound" => "Month(1) + Day(15)"
        )

        type_result = evalvalues(datetime_type_dict)
        @test isa(type_result["datetime"], DateTime)
        @test isa(type_result["date"], Date)
        @test isa(type_result["time"], Time)
        @test isa(type_result["period"], Month)
        @test isa(type_result["compound"], Dates.CompoundPeriod)
    end
end
