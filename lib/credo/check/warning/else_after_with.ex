defmodule Credo.Check.Warning.ElseAfterWith do
  @moduledoc """
  Using an `else` block right after a `with`, which has no `else` statement
  of its own, may be an unwanted semantic error.
  """

  @explanation [check: @moduledoc]

  use Credo.Check
  alias Credo.Code.Block

  @doc false
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:def, _meta, _arguments} = ast, issues, issue_meta) do
    case Block.all_blocks_for!(ast) do
      [do_block, else_block, nil, nil] when not is_nil(do_block) and not is_nil(else_block) ->
        issues_found = Credo.Code.prewalk(ast, &find_issues(&1, &2, issue_meta))

        {ast, issues ++ issues_found}
      _ ->
        {ast, issues}
    end
  end
  defp traverse(ast, issues, _issue_meta), do: {ast, issues}

  defp find_issues({:with, meta, arguments} = ast, issues, issue_meta) do
    case List.last(arguments) do
      [do: _do_block] ->
        issue = issue_for(issue_meta, meta[:line])
        {ast, issues ++ [issue]}
      _ ->
        {ast, issues}
    end
  end
  defp find_issues(ast, issues, _), do: {ast, issues}

  defp issue_for(issue_meta, line_no) do
    format_issue issue_meta,
      message: "Do not use an `else` block right after a `with` statement without its own `else`.",
      trigger: "else",
      line_no: line_no
  end
end
