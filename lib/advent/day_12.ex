defmodule Advent.Day12 do
  @moduledoc """
  N-body problem
  """

  @doc "Part 1"
  def total_energy(input, steps) do
    input
    |> parse()
    |> Enum.map(&build_moon/1)
    |> step_count(steps)
    |> Enum.map(&energy/1)
    |> Enum.sum()
  end

  @doc """
  Part 2

  Find repeat on individual axis and then calculate least common multiple of them, which will result in the total
  repeat

  Runs in ~1300ms.

  Optimizations that is not done yet:
   - Only run the simulation once until all axis repeats has been found. Right now it runs the simulation once per axis
  """
  def steps_to_repeat(input) do
    moons =
      input
      |> parse()
      |> Enum.map(&build_moon/1)

    0..2
    |> Enum.map(&find_axis_repeat(moons, &1))
    |> Enum.reduce(&lcm/2)
  end

  defp find_axis_repeat(moons, axis) do
    key_stream =
      moons
      |> Stream.unfold(fn moons ->
        key = moons |> Enum.flat_map(fn %{pos: pos, v: v} -> [elem(pos, axis), elem(v, axis)] end)
        {key, step(moons)}
      end)

    first = key_stream |> Enum.at(0)

    key_stream
    |> Stream.with_index()
    |> Stream.drop(1)
    |> Enum.find(&(elem(&1, 0) == first))
    |> elem(1)
  end

  defp energy(%{pos: {x, y, z}, v: {vx, vy, vz}}) do
    (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
  end

  defp step_count(moons, 0), do: moons

  defp step_count(moons, steps) do
    moons
    |> step()
    |> step_count(steps - 1)
  end

  defp step(moons) do
    moons
    |> apply_gravity()
    |> apply_velocity()
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
    |> Enum.map(fn {%{pos: {mx, my, mz}, v: velocity} = moon, other_moons} ->
      dv =
        other_moons
        |> Enum.reduce({0, 0, 0}, fn %{pos: {ox, oy, oz}}, {dx, dy, dz} ->
          {
            change_axis.(mx, ox, dx),
            change_axis.(my, oy, dy),
            change_axis.(mz, oz, dz)
          }
        end)

      v = add(velocity, dv)
      Map.put(moon, :v, v)
    end)
  end

  defp apply_velocity(moons) do
    moons
    |> Enum.map(fn %{pos: pos, v: velocity} = moon ->
      %{moon | pos: add(pos, velocity)}
    end)
  end

  defp add({x1, y1, z1}, {x2, y2, z2}), do: {x1 + x2, y1 + y2, z1 + z2}

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

  defp lcm(a, b), do: div(a * b, Integer.gcd(a, b))
end
