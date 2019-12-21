defmodule Advent.Day17Test do
  use ExUnit.Case, async: true

  alias Advent.Day17

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle input" do
      raw_program = File.read!("input_files/day_17.int")
      assert Day17.alignment_parameters_sum(raw_program) == 3292
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      raw_program = File.read!("input_files/day_17.int")
      assert Day17.find_robots(raw_program) == 651_043
    end
  end
end
