defmodule Advent.Day24Test do
  use ExUnit.Case, async: true

  alias Advent.Day24

  describe "part 1" do
    test "example 1" do
      input = """
      ....#
      #..#.
      #..##
      ..#..
      #....
      """

      assert Day24.first_duplicate(input) == 2_129_920
    end

    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_24.txt")
      assert Day24.first_duplicate(input) == 18_842_609
    end
  end
end
