defmodule Advent.Day03Test do
  use ExUnit.Case, async: true

  alias Advent.Day03

  describe "part 1" do
    test "example 1" do
      input = """
      R8,U5,L5,D3
      U7,R6,D4,L4
      """

      assert Day03.closest_intersection(input) == 6
    end

    test "example 2" do
      input = """
      R75,D30,R83,U83,L12,D49,R71,U7,L72
      U62,R66,U55,R34,D71,R55,D58,R83
      """

      assert Day03.closest_intersection(input) == 159
    end

    test "example 3" do
      input = """
      R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
      U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
      """

      assert Day03.closest_intersection(input) == 135
    end

    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_03.txt")
      assert Day03.closest_intersection(input) == 2050
    end
  end

  describe "part 2" do
    test "example 1" do
      input = """
      R8,U5,L5,D3
      U7,R6,D4,L4
      """

      assert Day03.fewest_steps_to_intersection(input) == 30
    end

    test "example 2" do
      input = """
      R75,D30,R83,U83,L12,D49,R71,U7,L72
      U62,R66,U55,R34,D71,R55,D58,R83
      """

      assert Day03.fewest_steps_to_intersection(input) == 610
    end

    test "example 3" do
      input = """
      R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
      U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
      """

      assert Day03.fewest_steps_to_intersection(input) == 410
    end

    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_03.txt")
      assert Day03.fewest_steps_to_intersection(input) == 21_666
    end
  end
end
