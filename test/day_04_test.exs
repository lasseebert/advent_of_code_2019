defmodule Advent.Day04Test do
  use Advent.Test.Case

  alias Advent.Day04

  describe "part 1" do
    test "puzzle input" do
      assert Day04.count_valid_passwords(278_384, 824_795) == 921
    end

    test "smaller input" do
      assert Day04.count_valid_passwords(278_384, 299_999) == 10
    end
  end

  describe "part 2" do
    test "puzzle input" do
      assert Day04.count_extended_valid_passwords(278_384, 824_795) == 603
    end
  end
end
