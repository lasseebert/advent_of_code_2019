defmodule Advent.Day21Test do
  use ExUnit.Case, async: true

  alias Advent.Day21

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle input" do
      raw_program = File.read!("input_files/day_21.int")
      assert Day21.walk(raw_program) == 19_359_996
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      raw_program = File.read!("input_files/day_21.int")
      assert Day21.run(raw_program) == 1_143_330_711
    end
  end
end
