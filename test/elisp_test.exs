defmodule ElispTest do
  use ExUnit.Case
  doctest Elisp

  test "greets the world" do
    assert Elisp.hello() == :world
  end
end
