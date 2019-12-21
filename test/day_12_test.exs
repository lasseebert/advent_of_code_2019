defmodule Advent.Day12Test do
  use ExUnit.Case, async: true

  alias Advent.Day12

  describe "part 1" do
    test "example 1" do
      input = """
      <x=-1, y=0, z=2>
      <x=2, y=-10, z=-7>
      <x=4, y=-8, z=8>
      <x=3, y=5, z=-1>
      """

      assert Day12.total_energy(input, 10) == 179
    end

    test "example 2" do
      input = """
      <x=-8, y=-10, z=0>
      <x=5, y=5, z=10>
      <x=2, y=-7, z=3>
      <x=9, y=-8, z=-3>
      """

      assert Day12.total_energy(input, 100) == 1940
    end

    @tag :puzzle_input
    test "puzzle_input" do
      input = File.read!("input_files/day_12.txt")
      assert Day12.total_energy(input, 1000) == 10_664
    end
  end
end
