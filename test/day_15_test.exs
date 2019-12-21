defmodule Advent.Day15Test do
  use ExUnit.Case, async: true

  alias Advent.Day15

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_15.int")
      assert Day15.shortest_dist(input) == 270
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_15.int")
      assert Day15.time_to_oxygen(input) == 364
    end
  end
end
