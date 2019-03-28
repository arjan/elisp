defmodule Elisp.ParserTest do
  use ExUnit.Case

  alias Elisp.Parser

  test "parser" do
    assert {:ok, []} == Parser.parse("; dddd\n")
    assert {:ok, []} == Parser.parse("; dddd\n\n; xx\n; \n")
    #    assert {:ok, [{:integer, 555}]} == Parser.parse("; dddd\n\n555")

    assert {:ok, [{:quoted, 123}]} == Parser.parse("'123")

    assert {:ok, [1]} == Parser.parse("1")
    assert {:ok, [123]} == Parser.parse("123")
    assert {:ok, [{:string, "aap"}]} == Parser.parse(~S("aap"))
    assert {:ok, [{:identifier, "aap"}]} == Parser.parse(~S(aap))
    assert {:ok, [{:identifier, "aap1"}]} == Parser.parse(~S(aap1))

    assert {:ok, [:dot]} == Parser.parse(~S(.))

    assert {:ok, [{:identifier, "aap"}, {:identifier, "noot"}]} ==
             Parser.parse(~S(aap      noot))

    assert {:ok, [{:string, "aap"}, 123]} == Parser.parse("\"aap\" 123")

    assert {:ok, [{:list, [123, 333, {:list, [{:string, "aa"}]}]}]} ==
             Parser.parse("(123 333 (\"aa\"))")

    assert {:ok, [{:list, []}]} ==
             Parser.parse("()")

    assert {:ok, [{:list, [123]}]} ==
             Parser.parse("  (   123  )\n\n ;; comment")

    for f <- Path.wildcard("test/fixture/*") do
      IO.inspect(f, label: "f")

      {:ok, ast} = Parser.parse(File.read!(f))
      IO.inspect(ast, label: "ast")
    end
  end
end
