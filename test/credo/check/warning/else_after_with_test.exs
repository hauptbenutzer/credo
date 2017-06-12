defmodule Credo.Check.Warning.ElseAfterWithTest do
  use Credo.TestHelper

  @described_check Credo.Check.Warning.ElseAfterWith

  test "it should report no violation when with appears in long form" do
"""
defmodule CredoSampleModule do
  use ExUnit.Case

  def catcher do
    with _ <- true do
      :yes
    end
  else
    _ -> :no
  end
end
""" |> to_source_file
    |> refute_issues(@described_check)
  end

  test "it should report no violation when else block appears after with with else" do
"""
defmodule CredoSampleModule do
  use ExUnit.Case

  def catcher do
    with _ <- true,
      do: :yes,
      else: _ -> :maybe
  else
    _ -> :no
  end
end
""" |> to_source_file
    |> refute_issues(@described_check)
  end

  test "it should report a violation when else block appears after with without else" do
"""
defmodule CredoSampleModule do
  use ExUnit.Case

  def catcher do
    with _ <- true,
      do: :yes
    else
      _ -> :no
  end
end
""" |> to_source_file
    |> assert_issue(@described_check, fn(issue) ->
        assert "else" == issue.trigger
        assert 5 == issue.line_no
      end)
  end
end
