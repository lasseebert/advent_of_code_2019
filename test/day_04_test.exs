defmodule Advent.Day04Test do
  use ExUnit.Case, async: true

  alias Advent.Day04

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle input" do
      assert Day04.count_valid_passwords(278_384, 824_795) == 921
    end

    test "smaller input" do
      assert Day04.count_valid_passwords(278_384, 299_999) == 10
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      assert Day04.count_extended_valid_passwords(278_384, 824_795) == 603
    end
  end
end
