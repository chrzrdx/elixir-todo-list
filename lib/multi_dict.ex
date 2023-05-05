defmodule MultiDict do
  @moduledoc """
  Documentation for `MultiDict`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> MultiDict.hello()
      :world

  """
  def new, do: %{}

  def add(dict, key, value) do
    Map.update(dict, key, [value], fn entries -> [value | entries] end)
  end

  def get(dict, key), do: Map.get(dict, key, [])
end
