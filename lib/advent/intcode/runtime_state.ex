defmodule Advent.Intcode.RuntimeState do
  @moduledoc """
  The runtime state of an Intcode program
  """

  alias Advent.Intcode

  @type t :: %__MODULE__{
          program: Intcode.program(),
          pointer: Intcode.address(),
          exited: boolean,
          caller: pid
        }

  defstruct [
    :program,
    :pointer,
    :exited,
    :caller
  ]

  @doc """
  Builds a new runtime state from a program and the input
  """
  @spec new(Intcode.program(), pid) :: t
  def new(program, caller) do
    %__MODULE__{
      program: program,
      pointer: 0,
      exited: false,
      caller: caller
    }
  end
end
