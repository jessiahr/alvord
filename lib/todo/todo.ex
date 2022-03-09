defmodule Todo do
  @store_name "todo.data"
  def add(item) do
    list = get_list()
    JsonStore.write(@store_name, %{list | "tasks" => [item] ++ Map.get(list, "tasks")})
  end

  def finish(index) do
    get_list()
    |> case do
      data = %{"tasks" => t, "finished" => f} ->
        {this_task, new_tasks} = t |> List.pop_at(index)

        JsonStore.write(@store_name, %{
          data
          | "tasks" => new_tasks,
            "finished" => [Map.put(this_task, "finished_at", DateTime.utc_now())] ++ f
        })

        IO.puts("Finished: #{Map.get(this_task, "title")}")

      data ->
        if Map.get(data, "finished") == nil do
          JsonStore.write(@store_name, Map.put(data, "finished", []))
          finish(index)
        end
    end
  end

  def print_list(todos) do
    IO.puts("Current TODO items:")
    IO.puts("[ID] [Title]")

    todos
    |> Enum.with_index()
    |> Enum.each(fn {item, index} ->
      case item do
        %{"title" => title} ->
          IO.puts(String.pad_trailing(Integer.to_string(index), 5) <> title)

          item
          |> Map.delete("title")
          |> Enum.map(fn {k, v} ->
            IO.puts("---- " <> String.pad_trailing(k, 10) <> ":" <> v)
          end)

          IO.puts("\n")

        other ->
          # do nothing its bad data
          nil
      end
    end)
  end

  @doc """
  Shorthand for adding a todo as kv pairs
  add docs for the thing/note: this is a note
  """
  def handle_args(["add" | items]) do
    items
    |> Enum.join(" ")
    |> String.split("/")
    |> Enum.map(fn s -> String.split(s, ":") end)
    |> Enum.reduce(%{}, fn row, acc ->
      case row do
        [h] ->
          Map.put(acc, "title", h)

        [h, t] ->
          Map.put(acc, h, t)
      end
    end)
    |> add()
  end

  def handle_args(["list" | item]) do
    get_list()
    |> Map.get("tasks")
    |> print_list()
  end

  def handle_args(["done"]) do
    get_list()
    |> Map.get("finished", [])
    |> print_list()
  end

  @doc """
  Interactive todo
  """
  def handle_args([]) do
    get_list()
    |> Map.get("tasks")
    |> print_list()

    case IO.gets("(A)dd or (F)inish a todo item? \n") do
      action when action in ["add\n", "a\n"] ->
        todo =
          IO.gets("Todo:\n")
          |> String.trim()
          |> String.split()

        handle_args(["add"] ++ todo)

      action when action in ["finish\n", "f\n"] ->
        IO.gets("Index:\n")
        |> String.trim()
        |> String.to_integer()
        |> finish()

      action when action in ["quit\n", "q\n"] ->
        nil
    end
  end

  defp get_list do
    case JsonStore.read(@store_name) do
      :error ->
        %{
          "tasks" => []
        }

      {:ok, data} ->
        data
    end
  end
end
