defmodule Advent.Day23Test do
  use ExUnit.Case, async: true

  alias Advent.Day23

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle input" do
      raw_program = File.read!("input_files/day_23.int")
      assert Day23.run(raw_program, false) == 20_665
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      raw_program = File.read!("input_files/day_23.int")
      assert Day23.run(raw_program, true) == 13_358
    end
  end
end
