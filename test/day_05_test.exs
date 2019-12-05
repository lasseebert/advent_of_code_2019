defmodule Advent.Day05Test do
  use Advent.Test.Case

  alias Advent.Day05

  describe "part 1" do
    test "puzzle input" do
      program = File.read!("input_files/day_05.txt")
      assert Day05.run_diagnostics(program, 1) == 14_155_342
    end
  end

  describe "part 2" do
    test "example 1" do
      program = "3,9,8,9,10,9,4,9,99,-1,8"
      assert Day05.run_diagnostics(program, 5) == 0
      assert Day05.run_diagnostics(program, 8) == 1
    end

    test "puzzle input" do
      program = File.read!("input_files/day_05.txt")
      assert Day05.run_diagnostics(program, 5) == 8_684_145
    end
  end
end
