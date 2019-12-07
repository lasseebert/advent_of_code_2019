defmodule Advent.Intcode.Supervisor do
  @moduledoc """
  Supervises Intcode programs
  """

  alias Advent.Intcode.Runner
  alias Advent.Intcode.RuntimeState

  use DynamicSupervisor

  @name __MODULE__

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: @name)
  end

  @doc """
  Starts an Intcode runtime and runs it in a supervised process
  """
  @spec run(RuntimeState.t()) :: :ok
  def run(state) do
    {:ok, _pid} = DynamicSupervisor.start_child(@name, {Runner, state})
    :ok
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
