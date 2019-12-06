defmodule Advent.Day02Test do
  use Advent.Test.Case

  alias Advent.Day02

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle input" do
      assert "input_files/day_02.txt" |> File.read!() |> Day02.part_1(12, 2) == 4_138_658
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      assert "input_files/day_02.txt" |> File.read!() |> Day02.part_2(19_690_720) == 7264
    end
  end
end
