defimpl DBI, for: DBI.PostgreSQL do

  use DBI.Implementation

  alias DBI.PostgreSQL, as: T
  alias :pgsql, as: P
  alias DBI.PostgreSQL.Error

  def query(%T{conn: conn}, statement, []) do
    process_result(P.equery(conn, statement), statement, [])
  end
  def query(%T{conn: conn}, statement, bindings) do
    parsed_statement = DBI.Statement.parse(statement)
    {expr, bindings_list} =
    Enum.reduce(parsed_statement, {"", []}, fn
      item, {expr, bindings_list} when is_atom(item) ->
        {expr <> "$#{length(bindings_list) + 1}", [(bindings[item]||:null)|bindings_list]}
      item, {expr, bindings_list} ->
        {expr <> item, bindings_list}
    end)
    bindings_list = Enum.reverse bindings_list
    process_result(P.equery(conn, expr, bindings_list), statement, bindings)
  end

  defp process_result(list, statement, bindings) when is_list(list) do
    for item <- list, do: process_result(item, statement, bindings)
  end
  defp process_result({:ok, columns, rows}, statement, bindings) do
    process_result({:ok, nil, columns, rows}, statement, bindings)
  end
  defp process_result({:ok, count}, _statement, _bindings) do
    {:ok, %Result{count: count}}
  end
  defp process_result({:ok, count, columns, rows}, _statement, _bindings) do
    column_names = for {:column, name, _type, _size, _modifier, _format} <- columns, do: name
    {:ok, %Result{count: count, columns: column_names, rows: rows}}
  end
  defp process_result({:error, {:error, severity, code, description, extra}}, statement, bindings) do
    {:error, %Error{severity: severity, code: code, description: description, extra: extra,
                   statement: statement, bindings: bindings}}
  end
end