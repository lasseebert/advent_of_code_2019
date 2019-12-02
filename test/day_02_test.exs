defmodule Advent.Day02Test do
  use Advent.Test.Case

  alias Advent.Day02

  describe "part 1" do
    test "example 1" do
      assert Day02.part_1("1,9,10,3,2,3,11,0,99,30,40,50", 9, 10) == 3500
    end

    test "example 2" do
      assert Day02.part_1("1,0,0,0,99", 0, 0) == 2
    end

    test "example 3" do
      assert Day02.part_1("2,3,0,3,99", 3, 0) == 2
    end

    test "example 4" do
      assert Day02.part_1("1,1,1,4,99,5,6,0,99", 1, 1) == 30
    end

    test "real input" do
      assert "input_files/day_02.txt" |> File.read!() |> Day02.part_1(12, 2) == 4_138_658
    end
  end

  describe "part 2" do
    test "real input" do
      assert "input_files/day_02.txt" |> File.read!() |> Day02.part_2(19_690_720) == 7264
    end
  end
end
