defmodule TodoList do
  @moduledoc """
  Documentation for `TodoList`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> TodoList.new()
      %{}

  """
  def new(), do: MultiDict.new()

  def add_entry(todos, %{date: date, title: title}) do
    MultiDict.add(todos, date, title)
  end

  def entries(todos, date), do: MultiDict.get(todos, date)

  def test() do
    new()
    |> add_entry(%{date: ~D[2023-05-03], title: "get groceries"})
    |> add_entry(%{date: ~D[2023-05-02], title: "write journal"})
    |> add_entry(%{date: ~D[2023-05-05], title: "buy coconut"})
    |> add_entry(%{date: ~D[2023-05-03], title: "sell feet pics"})
    |> add_entry(%{date: ~D[2023-05-03], title: "redeem coupon"})
    |> add_entry(%{date: ~D[2023-05-02], title: "sing a song"})
    |> entries(~D[2023-05-03])
  end
end
