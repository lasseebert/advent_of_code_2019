defmodule Advent.Day06Test do
  use Advent.Test.Case

  alias Advent.Day06

  describe "part 1" do
    test "example 1" do
      input = """
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
      """

      assert Day06.count_total_orbits(input) == 42
    end

    test "puzzle input" do
      input = File.read!("input_files/day_06.txt")
      assert Day06.count_total_orbits(input) == 140_608
    end
  end

  describe "part 2" do
    test "example 1" do
      input = """
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
      K)YOU
      I)SAN
      """

      assert Day06.travel_distance(input, "YOU", "SAN") == 4
    end

    test "puzzle input" do
      input = File.read!("input_files/day_06.txt")
      assert Day06.travel_distance(input, "YOU", "SAN") == 337
    end
  end
end
