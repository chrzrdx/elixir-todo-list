defmodule Todo.List.CsvImporter do
  def import(path) do
    TodoList.new(
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.split(&1, ",", take: 2))
      |> Stream.map(fn [date_string, title] ->
        with {:ok, date} <- parse_date(date_string) do
          %{date: date, title: title}
        else
          _error -> nil
        end
      end)
      |> Enum.filter(&(&1 != nil))
    )
  end

  def parse_date(date_str) do
    [year, month, day] = date_str |> String.split("/") |> Enum.map(&String.to_integer/1)
    Date.new(year, month, day)
  end

  def test() do
    Todo.List.CsvImporter.import("./test/sample_todo_list.csv")
  end
end
