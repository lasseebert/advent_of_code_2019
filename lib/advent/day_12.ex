defmodule Advent.Day12 do
  @moduledoc """
  N-body problem
  """

  @doc "Part 1"
  def total_energy(input, steps) do
    input
    |> parse()
    |> Enum.map(&build_moon/1)
    |> step(steps)
    |> Enum.map(&energy/1)
    |> Enum.sum()
  end

  defp energy(%{pos: {x, y, z}, v: {vx, vy, vz}}) do
    (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
  end

  defp step(moons, 0), do: moons

  defp step(moons, steps) do
    moons
    |> apply_gravity()
    |> apply_velocity()
    |> step(steps - 1)
  end

  defp apply_gravity(moons) do
    change_axis = fn moon_axis, other_moon_axis, change_axis ->
      cond do
        moon_axis > other_moon_axis -> change_axis - 1
        moon_axis < other_moon_axis -> change_axis + 1
        moon_axis == other_moon_axis -> change_axis
      end
    end

    moons
    |> Enum.map(&{&1, moons -- [&1]})
    |> Enum.map(fn {%{pos: {mx, my, mz}, v: {vx, vy, vz}} = moon, other_moons} ->
      {dx, dy, dz} =
        other_moons
        |> Enum.reduce({0, 0, 0}, fn %{pos: {ox, oy, oz}}, {dx, dy, dz} ->
          {
            change_axis.(mx, ox, dx),
            change_axis.(my, oy, dy),
            change_axis.(mz, oz, dz)
          }
        end)

      v = {vx + dx, vy + dy, vz + dz}
      Map.put(moon, :v, v)
    end)
  end

  defp apply_velocity(moons) do
    moons
    |> Enum.map(fn %{pos: {x, y, z}, v: {vx, vy, vz}} = moon ->
      Map.put(moon, :pos, {x + vx, y + vy, z + vz})
    end)
  end

  defp build_moon(pos) do
    %{pos: pos, v: {0, 0, 0}}
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.replace(~r/[<>xyz=]/, "")
      |> String.split(", ")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end
end
