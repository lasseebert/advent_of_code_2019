defmodule Advent.IntcodeTest do
  use Advent.Test.Case

  alias Advent.Intcode

  setup do
    start_supervised!(Advent.Intcode.Supervisor)
    :ok
  end

  test "day 05 example 1" do
    program = "3,9,8,9,10,9,4,9,99,-1,8" |> Intcode.parse_program()

    Intcode.run(program)
    receive(do: ({:input, pid} -> send(pid, {:input, 5})))
    assert_receive({:output, 0})

    Intcode.run(program)
    receive(do: ({:input, pid} -> send(pid, {:input, 8})))
    assert_receive({:output, 1})
  end
end
