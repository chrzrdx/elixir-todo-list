defmodule MultiDict do
  def new, do: %{}

  def add(dict, key, value) do
    Map.update(dict, key, [value], fn entries -> [value | entries] end)
  end

  def delete(dict, key), do: Map.delete(dict, key)

  def delete(dict, key, _) when not is_map_key(dict, key), do: dict

  def delete(dict, key, value) do
    case get(dict, key) do
      [^value] ->
        delete(dict, key)

      existing_values when is_list(existing_values) ->
        Map.put(dict, key, List.delete(existing_values, value))
    end
  end

  def get(dict, key), do: Map.get(dict, key, [])
end
