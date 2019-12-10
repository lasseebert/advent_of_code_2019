defmodule Advent.Day10Test do
  use Advent.Test.Case

  alias Advent.Day10

  describe "part 1" do
    test "example 1" do
      input = """
      .#..#
      .....
      #####
      ....#
      ...##
      """

      assert Day10.best_location(input) == 8
    end

    test "example 2" do
      input = """
      ......#.#.
      #..#.#....
      ..#######.
      .#.#.###..
      .#..#.....
      ..#....#.#
      #..#....#.
      .##.#..###
      ##...#..#.
      .#....####
      """

      assert Day10.best_location(input) == 33
    end

    test "example 3" do
      input = """
      #.#...#.#.
      .###....#.
      .#....#...
      ##.#.#.#.#
      ....#.#.#.
      .##..###.#
      ..#...##..
      ..##....##
      ......#...
      .####.###.
      """

      assert Day10.best_location(input) == 35
    end

    test "example 4" do
      input = """
      .#..#..###
      ####.###.#
      ....###.#.
      ..###.##.#
      ##.##.#.#.
      ....###..#
      ..#.#..#.#
      #..#.#.###
      .##...##.#
      .....#.#..
      """

      assert Day10.best_location(input) == 41
    end

    test "example 5" do
      input = """
      .#..##.###...#######
      ##.############..##.
      .#.######.########.#
      .###.#######.####.#.
      #####.##.#.##.###.##
      ..#####..#.#########
      ####################
      #.####....###.#.#.##
      ##.#################
      #####.##.###..####..
      ..######..##.#######
      ####.##.####...##..#
      .#####..#.######.###
      ##...#.##########...
      #.##########.#######
      .####.#.###.###.#.##
      ....##.##.###..#####
      .#.#.###########.###
      #.#.#.#####.####.###
      ###.##.####.##.#..##
      """

      assert Day10.best_location(input) == 210
    end

    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_10.txt")
      assert Day10.best_location(input) == 340
    end
  end

  describe "part 2" do
    test "example 1" do
      input = """
      .#..##.###...#######
      ##.############..##.
      .#.######.########.#
      .###.#######.####.#.
      #####.##.#.##.###.##
      ..#####..#.#########
      ####################
      #.####....###.#.#.##
      ##.#################
      #####.##.###..####..
      ..######..##.#######
      ####.##.####...##..#
      .#####..#.######.###
      ##...#.##########...
      #.##########.#######
      .####.#.###.###.#.##
      ....##.##.###..#####
      .#.#.###########.###
      #.#.#.#####.####.###
      ###.##.####.##.#..##
      """

      assert Day10.vaporized(input, 200) == 802
    end

    @tag :puzzle_input
    test "puzzle input" do
      input = File.read!("input_files/day_10.txt")
      assert Day10.vaporized(input, 200) == 2628
    end
  end

  describe "direction" do
    test "{0, 0} -> {0, 5}" do
      assert Day10.direction({0, 0}, {0, 5}) == {0, 1}
    end

    test "{0, 0} -> {5, 0}" do
      assert Day10.direction({0, 0}, {5, 0}) == {1, 0}
    end

    test "{0, 0} -> {4, 6}" do
      assert Day10.direction({0, 0}, {4, 6}) == {2, 3}
    end

    test "{0, 0} -> {-4, -6}" do
      assert Day10.direction({0, 0}, {-4, -6}) == {-2, -3}
    end
  end
end
