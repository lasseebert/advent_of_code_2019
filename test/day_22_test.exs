defmodule Advent.Day22Test do
  use ExUnit.Case, async: true

  alias Advent.Day22

  describe "part 1" do
    test "example 1" do
      input = """
      deal with increment 7
      deal into new stack
      deal into new stack
      """

      assert Enum.sort_by(0..9, &Day22.shuffle(input, 10, &1)) == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
    end

    test "example 2" do
      input = """
      cut 6
      deal with increment 7
      deal into new stack
      """

      assert Enum.sort_by(0..9, &Day22.shuffle(input, 10, &1)) == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]
    end

    test "example 3" do
      input = """
      deal with increment 7
      deal with increment 9
      cut -2
      """

      assert Enum.sort_by(0..9, &Day22.shuffle(input, 10, &1)) == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]
    end

    test "example 4" do
      input = """
      deal into new stack
      cut -2
      deal with increment 7
      cut 8
      cut -4
      deal with increment 7
      cut 3
      deal with increment 9
      deal with increment 3
      cut -1
      """

      assert Enum.sort_by(0..9, &Day22.shuffle(input, 10, &1)) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
    end

    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_22.txt")
      assert Day22.shuffle(input, 10_007, 2019) == 2322
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    @tag :skip
    test "puzzle input" do
      input = File.read!("input_files/day_22.txt")
      assert Day22.shuffle_mult(input, 119_315_717_514_047, 2020, 101_741_582_076_661) == :foo
      # 89381792938121 is too high
    end
  end
end
