defmodule Advent.Day18Test do
  use Advent.Test.Case

  alias Advent.Day18

  describe "part 1" do
    test "example 1" do
      input = """
      #########
      #b.A.@.a#
      #########
      """

      assert Day18.shortest_path(input) == 8
    end

    test "example 2" do
      input = """
      ########################
      #f.D.E.e.C.b.A.@.a.B.c.#
      ######################.#
      #d.....................#
      ########################
      """

      assert Day18.shortest_path(input) == 86
    end

    test "example 3" do
      input = """
      ########################
      #...............b.C.D.f#
      #.######################
      #.....@.a.B.c.d.A.e.F.g#
      ########################
      """

      assert Day18.shortest_path(input) == 132
    end

    test "example 4" do
      input = """
      #################
      #i.G..c...e..H.p#
      ########.########
      #j.A..b...f..D.o#
      ########@########
      #k.E..a...g..B.n#
      ########.########
      #l.F..d...h..C.m#
      #################
      """

      assert Day18.shortest_path(input) == 136
    end

    test "example 5" do
      input = """
      ########################
      #@..............ac.GI.b#
      ###d#e#f################
      ###A#B#C################
      ###g#h#i################
      ########################
      """

      assert Day18.shortest_path(input) == 81
    end

    @tag :puzzle_input
    @tag timeout: :infinity
    test "puzzle input" do
      input = File.read!("input_files/day_18.txt")
      assert Day18.shortest_path(input) == 3764
    end
  end
end
