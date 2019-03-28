defmodule Elisp.ParserTest do
  use ExUnit.Case

  alias Elisp.Parser

  test "parser" do
    assert {:ok, []} == Parser.parse("; dddd\n\n; xx\n;\n")

    assert {:ok, [{:integer, 1}]} == Parser.parse("1")
    assert {:ok, [{:integer, 123}]} == Parser.parse("123")
    assert {:ok, [{:string, "aap"}]} == Parser.parse(~S("aap"))
    assert {:ok, [{:identifier, "aap"}]} == Parser.parse(~S(aap))
    assert {:ok, [{:identifier, "aap1"}]} == Parser.parse(~S(aap1))

    assert {:ok, [{:identifier, "aap"}, {:identifier, "noot"}]} ==
             Parser.parse(~S(aap      noot))

    assert {:ok, [{:string, "aap"}, {:integer, 123}]} == Parser.parse("\"aap\" 123")

    assert {:ok, [{:list, [{:integer, 123}, {:integer, 333}, {:list, [{:string, "aa"}]}]}]} ==
             Parser.parse("(123 333 (\"aa\"))")

    assert {:ok, [{:list, []}]} ==
             Parser.parse("()")

    assert {:ok, [{:list, [{:integer, 123}]}]} ==
             Parser.parse("  (   123  )\n\n ;; comment")

    assert {:ok, ast} = Parser.parse(~s/
(global-set-key
 "\M-x"
 (lambda ()
   (interactive)
   (call-interactively
   (intern
     (ido-completing-read
      "M-x "
      (all-completions "" obarray commandp))))))
/)
    IO.inspect(ast, label: "ast")
  end
end
