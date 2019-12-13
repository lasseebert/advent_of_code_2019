defmodule Advent.Day11Test do
  use Advent.Test.Case

  alias Advent.Day11

  describe "part 1" do
    @tag :puzzle_input
    test "puzzle input" do
      program = File.read!("input_files/day_11.int")
      assert Day11.paint(program) == 2322
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      program = File.read!("input_files/day_11.int")

      assert Day11.paint_again(program) ==
               """
                  ## #  #  ##  ###  ###   ##   ##  #  #   
                   # #  # #  # #  # #  # #  # #  # #  #   
                   # #### #  # #  # ###  #    #    #  #   
                   # #  # #### ###  #  # # ## #    #  #   
                #  # #  # #  # # #  #  # #  # #  # #  #   
                 ##  #  # #  # #  # ###   ###  ##   ##    
               """
    end
  end
end
