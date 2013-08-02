defexception DBI.PostgreSQL.Error, severity: nil, code: nil, description: nil, extra: nil,
								   statement: nil, bindings: nil do
  def message(__MODULE__[severity: severity, code: code,
                         description: description, statement: statement, bindings: bindings]) do
    """
    (#{severity}) #{code} #{description} while executing

    #{statement}

    Bindings:

      #{inspect bindings, pretty: true}
    """
  end
end