defmodule Advent.Day06 do
  @moduledoc """
  Orbits!
  """

  @doc """
  Part 1

  Build a map of bodies from inner to outer (each body points to a list of bodies orbiting it)
  Recursively go through the map from COM and add distances to COM for each body.
  """
  def count_total_orbits(input) do
    input
    |> parse()
    |> build_outgoing_orbit_map()
    |> count_total_orbits("COM", 0)
  end

  @doc """
  Part 2

  Build a map of bodies from outer to inner
  Travel the path from each of the two bodies to COM
  Find first common body and add the distances of the two travels

  Runs in ~1 ms
  """
  def travel_distance(input, from, to) do
    orbit_map =
      input
      |> parse()
      |> build_ingoing_orbit_map()

    from_path_map = travel_to_center_of_mass(orbit_map, from) |> Enum.into(%{})

    {to_intersection, to_dist} =
      orbit_map
      |> travel_to_center_of_mass(to)
      |> Enum.find(&Map.has_key?(from_path_map, elem(&1, 0)))

    from_dist = Map.fetch!(from_path_map, to_intersection)

    # Subtract 2, since we're only going from the body YOU orbits to the body SAN orbits.
    # We don't go from YOU or to SAN.
    to_dist + from_dist - 2
  end

  defp travel_to_center_of_mass(orbit_map, from) do
    Stream.iterate({from, 0}, fn {from, distance} -> {Map.get(orbit_map, from), distance + 1} end)
    |> Stream.take_while(fn {body, _distance} -> body != nil end)
  end

  defp count_total_orbits(orbit_map, center, distance) do
    orbits = Map.get(orbit_map, center, [])
    distance = distance + 1

    Enum.reduce(orbits, length(orbits) * distance, fn inner_center, sum ->
      sum + count_total_orbits(orbit_map, inner_center, distance)
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [center, body] = String.split(line, ")")
      {center, body}
    end)
  end

  defp build_outgoing_orbit_map(pairs) do
    pairs
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.into(%{})
  end

  defp build_ingoing_orbit_map(pairs) do
    pairs
    |> Enum.into(%{}, fn {center, body} -> {body, center} end)
  end
end
