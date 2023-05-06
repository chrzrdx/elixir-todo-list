defmodule TodoList do
  defstruct auto_id: 1,
            entries: %{},
            entries_by_date: MultiDict.new()

  def new(), do: %TodoList{}

  def add_entry(
        %TodoList{entries: entries, entries_by_date: entries_by_date, auto_id: auto_id} = todos,
        %{date: date, title: title}
      ) do
    new_todo = %{id: auto_id, date: date, title: title}
    new_entries = Map.put(entries, auto_id, new_todo)
    new_entries_by_date = MultiDict.add(entries_by_date, date, auto_id)

    %{todos | auto_id: auto_id + 1, entries: new_entries, entries_by_date: new_entries_by_date}
  end

  def get_entry_by_id(%TodoList{} = todos, id) do
    todos.entries |> Map.get(id)
  end

  def update_entry(
        %TodoList{entries: entries, entries_by_date: entries_by_date} = todos,
        id,
        update_fn
      ) do
    case get_entry_by_id(todos, id) do
      nil ->
        todos

      todo ->
        updated_todo = Map.merge(todo, update_fn.(todo))

        new_entries = Map.put(entries, todo.id, updated_todo)

        new_entries_by_date =
          if updated_todo.date != todo.date do
            entries_by_date
            |> MultiDict.delete(todo.date, todo.id)
            |> MultiDict.add(updated_todo.date, todo.id)
          else
            entries_by_date
          end

        %{todos | entries: new_entries, entries_by_date: new_entries_by_date}
    end
  end

  def delete_entry(
        %TodoList{entries: entries, entries_by_date: entries_by_date} = todos,
        id
      ) do
    case get_entry_by_id(todos, id) do
      nil ->
        todos

      todo ->
        new_entries = Map.delete(entries, todo.id)

        new_entries_by_date =
          entries_by_date
          |> MultiDict.delete(todo.date, todo.id)

        %TodoList{todos | entries: new_entries, entries_by_date: new_entries_by_date}
    end
  end

  def entries(%TodoList{entries: entries, entries_by_date: entries_by_date}, date) do
    entries_by_date
    |> MultiDict.get(date)
    |> Stream.map(&Map.get(entries, &1))
    |> IO.inspect()
    |> Enum.map(&Map.get(&1, :title))
  end

  def test() do
    new()
    |> add_entry(%{date: ~D[2023-05-03], title: "get groceries"})
    |> add_entry(%{date: ~D[2023-05-02], title: "write journal"})
    |> add_entry(%{date: ~D[2023-05-05], title: "buy coconut"})
    |> add_entry(%{date: ~D[2023-05-03], title: "sell feet pics"})
    |> add_entry(%{date: ~D[2023-05-03], title: "redeem coupon"})
    |> add_entry(%{date: ~D[2023-05-02], title: "sing a song"})
    |> update_entry(6, fn _ -> %{date: ~D[2023-05-02], title: "sing a lullaby"} end)
    |> update_entry(3, fn _ -> %{title: "buy banana"} end)
    |> update_entry(3, fn _ -> %{date: ~D[2023-05-02]} end)
    |> update_entry(3, fn _ -> %{date: ~D[2023-05-06]} end)
    |> add_entry(%{date: ~D[2023-05-03], title: "jog 5km"})
    |> delete_entry(4)
  end
end
