# --- Test Suite ---
@testset "dict2nt: Dictionary to NamedTuple Conversion" begin

    @testset "Basic Conversion" begin
        d1 = Dict(:a => 1, :b => "hello", :c => 3.14)
        nt1 = dict2nt(d1)
        @test nt1 isa NamedTuple
        @test nt1 == (a=1, b="hello", c=3.14)
        @test nt1.a == 1
        @test nt1.b == "hello"
    end

    @testset "Nested Dictionary" begin
        d2 = Dict(:a => 1, :b => Dict(:c => 2, :d => 3))
        nt2 = dict2nt(d2)
        @test nt2 isa NamedTuple
        @test nt2.b isa NamedTuple
        @test nt2.b.c == 2
        @test nt2.b.d == d2[:b][:d]
    end

    @testset "Deeply Nested Dictionary" begin
        d3 = Dict(
            :level1 => Dict(
                :level2a => Dict(:val1 => 10, :val2 => 20),
                :level2b => Dict(
                    :level3 => Dict(:deep_val => "found_it")
                )
            ),
            :top_level => 99
        )
        nt3 = dict2nt(d3)
        @test nt3.level1.level2b.level3.deep_val == "found_it"
        @test nt3.top_level == 99

    end

    @testset "Empty Dictionary" begin
        d_empty = Dict()
        nt_empty = dict2nt(d_empty)
        @test nt_empty isa NamedTuple
        @test nt_empty == NamedTuple()
        @test isempty(keys(nt_empty))
    end

    @testset "Nested Empty Dictionary" begin
        d_nested_empty = Dict(:a => 1, :b => Dict())
        nt_nested_empty = dict2nt(d_nested_empty)
        @test nt_nested_empty.b isa NamedTuple
        @test isempty(keys(nt_nested_empty.b))
        @test nt_nested_empty == (a=1, b=NamedTuple())
    end

    @testset "Mixed Value Types" begin
        d4 = Dict(
            :an_int => 10,
            :a_string => "Julia",
            :a_float => 99.9,
            :an_array => [1, 2, 3],
            :a_tuple => (4, 5),
            :nested_dict => Dict(:key => "value")
        )
        nt4 = dict2nt(d4)
        @test nt4.an_array == [1, 2, 3]
        @test nt4.a_tuple == (4, 5)
        @test nt4.nested_dict.key == "value"
        @test nt4.an_int === 10
    end

    @testset "String Keys Conversion" begin
        d5 = Dict("a" => 1, "b" => Dict("c" => 2))
        nt5 = dict2nt(d5)
        @test nt5 isa NamedTuple
        @test (keys(nt5) == (:a, :b)) || (keys(nt5) == (:b, :a)) # Keys should be converted to Symbols
        @test keys(nt5.b) == (:c,)
        @test nt5.a == 1
        @test nt5.b.c == 2
    end

    @testset "Mixed Symbol and String Keys" begin
        d6 = Dict("key1" => "string_key", :key2 => "symbol_key")
        nt6 = dict2nt(d6)
        @test nt6.key1 == "string_key"
        @test nt6.key2 == "symbol_key"
        @test sort(collect(keys(nt6))) == [:key1, :key2]
    end

end
