defmodule Advent.Day01Test do
  use Advent.Test.Case, async: true

  alias Advent.Day01

  describe "part 1" do
    test "example 1" do
      input = """
      12
      """

      assert Day01.required_fuel(input) == 2
    end

    test "example 2" do
      input = """
      14
      """

      assert Day01.required_fuel(input) == 2
    end

    test "example 3" do
      input = """
      1969
      """

      assert Day01.required_fuel(input) == 654
    end

    test "example 4" do
      input = """
      100756
      """

      assert Day01.required_fuel(input) == 33_583
    end

    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_01.txt")
      assert Day01.required_fuel(input) == 3_231_195
    end
  end

  describe "part 2" do
    test "example 1" do
      input = """
      12
      """

      assert Day01.required_fuel_recursive(input) == 2
    end

    test "example 2" do
      input = """
      14
      """

      assert Day01.required_fuel_recursive(input) == 2
    end

    test "example 3" do
      input = """
      1969
      """

      assert Day01.required_fuel_recursive(input) == 966
    end

    test "example 4" do
      input = """
      100756
      """

      assert Day01.required_fuel_recursive(input) == 50_346
    end

    test "multiple values" do
      input = """
      14
      14
      14
      14
      14
      """

      assert Day01.required_fuel_recursive(input) == 10
    end

    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_01.txt")
      assert Day01.required_fuel_recursive(input) == 4_843_929
    end
  end
end
