defmodule Advent.Day01 do
  @moduledoc """
  Not optimized in any special way. Runs in ~0.2ms
  """

  @doc "Part 1"
  @spec required_fuel(String.t()) :: integer
  def required_fuel(input) do
    input
    |> parse
    |> Enum.map(&single_required_fuel/1)
    |> Enum.sum()
  end

  @doc "Part 2"
  @spec required_fuel_recursive(String.t()) :: integer
  def required_fuel_recursive(input) do
    input
    |> parse
    |> Enum.map(&single_required_fuel/1)
    |> Enum.map(&add_fuel_recursively/1)
    |> Enum.sum()
  end

  defp add_fuel_recursively(mass) when mass > 0 do
    new_mass = mass |> single_required_fuel() |> add_fuel_recursively()
    mass + new_mass
  end

  defp add_fuel_recursively(0), do: 0

  defp single_required_fuel(mass) do
    case div(mass, 3) - 2 do
      n when n > 0 -> n
      n when n <= 0 -> 0
    end
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
