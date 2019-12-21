defmodule Advent.Day19Test do
  use ExUnit.Case, async: true

  alias Advent.Day19

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle input" do
      raw_program = File.read!("input_files/day_19.int")
      assert Day19.count_50x50(raw_program) == 186
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      raw_program = File.read!("input_files/day_19.int")
      assert Day19.minimum_distance(raw_program) == 9_231_141
    end
  end
end
