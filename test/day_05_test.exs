defmodule Advent.Day05Test do
  use ExUnit.Case, async: true

  alias Advent.Day05

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle input" do
      program = File.read!("input_files/day_05.txt")
      assert Day05.run_diagnostics(program, 1) == 14_155_342
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      program = File.read!("input_files/day_05.txt")
      assert Day05.run_diagnostics(program, 5) == 8_684_145
    end
  end
end
