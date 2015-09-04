module IgnoreColumns
  def ignore_columns(*ignored_columns)
    default_scope { select(column_names - ignored_columns.map(&:to_s)) }
  end

  def count
    # The default scope breaks the regular `count` method, due to
    # `COUNT(co1, col2, ...)` being invalid SQL syntax. This workaround seems to
    # work for most cases.
    pluck('count(*)').first
  end
end
