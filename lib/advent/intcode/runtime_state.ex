defmodule Advent.Intcode.RuntimeState do
  @moduledoc """
  The runtime state of an Intcode program
  """

  alias Advent.Intcode

  @type t :: %__MODULE__{
          program: Intcode.program(),
          pointer: Intcode.address(),
          exited: boolean,
          relative_base: Intcode.address(),
          io: function | nil,
          caller_state: any
        }

  defstruct [
    :program,
    :pointer,
    :exited,
    :relative_base,
    :io,
    :caller_state
  ]

  @doc """
  Builds a new runtime state from a program and the input
  """
  @spec new(Intcode.program()) :: t
  def new(program) do
    %__MODULE__{
      program: program,
      pointer: 0,
      exited: false,
      relative_base: 0,
      io: nil,
      caller_state: nil
    }
  end
end
