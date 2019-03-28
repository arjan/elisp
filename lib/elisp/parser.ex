defmodule Elisp.Parser.Helper do
  import NimbleParsec

  def ws(p \\ empty()) do
    p |> ascii_string([9, 10, 11, 12, 13, 32], min: 1)
  end

  def opt_ws(p \\ empty()) do
    p
    # ignore all direct whitespace
    |> optional(ignore(ws()))
    # comment
    |> optional(
      ignore(ascii_char([?;]) |> utf8_string([], min: 1) |> choice([ascii_char([10]), eos()]))
    )
  end
end

defmodule Elisp.Parser do
  import NimbleParsec
  import Elisp.Parser.Helper

  integer =
    integer(min: 1)
    |> unwrap_and_tag(:integer)

  identifier =
    ascii_char([?a..?z])
    |> optional(repeat(ascii_char([?a..?z, ?0..?9, ?-])))
    |> tag(:identifier)
    |> map({__MODULE__, :to_binary, []})

  string =
    ignore(ascii_char([?"]))
    |> repeat(
      lookahead_not(ascii_char([?"]))
      |> choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ])
    )
    |> ignore(ascii_char([?"]))
    |> tag(:string)
    |> map({__MODULE__, :to_binary, []})

  def to_binary({tag, s}), do: {tag, to_string(s)}

  list =
    ignore(ascii_char([40]))
    |> opt_ws()
    |> concat(parsec(:list_inner))
    |> opt_ws()
    |> ignore(ascii_char([41]))
    |> tag(:list)

  defcombinatorp(
    :item,
    choice([identifier, integer, string, list])
  )

  defcombinatorp(
    :list_inner,
    optional(parsec(:item))
    |> optional(
      repeat(
        concat(
          ignore(ws()),
          parsec(:item)
        )
      )
    )
  )

  #  defparsec(:toplevel, choice([opt_ws(), opt_ws() |> parsec(:list_inner) |> opt_ws()]))
  defparsec(:toplevel, choice([opt_ws() |> parsec(:list_inner) |> opt_ws(), opt_ws()]))

  def parse(code) do
    case toplevel(code) do
      {:ok, result, "", _, _, _} ->
        {:ok, result}

      {:ok, _result, _, _, _, _} ->
        {:error, "Garbage at end of input"}

      e ->
        {:error, :parse_error, e}
    end
  end
end
