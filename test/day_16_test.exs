defmodule Advent.Day16Test do
  use ExUnit.Case, async: true

  alias Advent.Day16

  describe "part 1" do
    test "example 1" do
      assert Day16.fft("12345678", 1) == "48226158"
      assert Day16.fft("12345678", 2) == "34040438"
      assert Day16.fft("12345678", 3) == "03415518"
      assert Day16.fft("12345678", 4) == "01029498"
    end

    test "example 2" do
      assert Day16.fft("80871224585914546619083218645595", 100) == "24176176"
    end

    test "example 3" do
      assert Day16.fft("19617804207202209144916044189917", 100) == "73745418"
    end

    test "example 4" do
      assert Day16.fft("69317163492948606335995924319873", 100) == "52432133"
    end

    @tag :puzzle_input
    test "puzzle input" do
      numbers = File.read!("input_files/day_16.txt")
      assert Day16.fft(numbers, 100) == "53296082"
    end
  end

  describe "part 2" do
    test "example 1" do
      assert Day16.fft_mult_offset("03036732577212944063491565474664", 100) == "84462026"
    end

    test "example 3" do
      assert Day16.fft_mult_offset("02935109699940807407585447034323", 100) == "78725270"
    end

    test "example 4" do
      assert Day16.fft_mult_offset("03081770884921959731165446850517", 100) == "53553731"
    end

    @tag :puzzle_input
    test "puzzle input" do
      numbers = File.read!("input_files/day_16.txt")
      assert Day16.fft_mult_offset(numbers, 100) == "43310035"
    end
  end
end
