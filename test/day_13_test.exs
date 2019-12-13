defmodule Advent.Day13Test do
  use Advent.Test.Case

  alias Advent.Day13

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle_input" do
      input = File.read!("input_files/day_13.int")
      assert Day13.count_blocks(input) == 301
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle_input" do
      input = File.read!("input_files/day_13.int")
      assert Day13.win_game(input) == 14_096
    end
  end
end
