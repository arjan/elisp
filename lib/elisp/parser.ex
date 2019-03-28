defmodule Elisp.Parser.Helper do
  import NimbleParsec

  def ws(p \\ empty()) do
    p |> ascii_string([9, 10, 11, 12, 13, 32], min: 1)
  end

  def eol(p \\ empty()) do
    ascii_char(p, [?\n])
  end

  def comment(p \\ empty()) do
    p
    |> ascii_char([?;])
    |> choice([
      utf8_string([not: ?\n], min: 1) |> eol(),
      utf8_string([], min: 1) |> eos(),
      eos(),
      eol()
    ])
  end

  def opt_ws(p \\ empty()) do
    p
    # eat all whitespace and comments
    |> ignore(
      optional(
        repeat(
          choice([
            ws(),
            comment()
          ])
        )
      )
    )
  end
end

defmodule Elisp.Parser do
  import NimbleParsec
  import Elisp.Parser.Helper

  integer =
    optional(ascii_char([?+, ?-]) |> unwrap_and_tag(:sign))
    |> integer(min: 1)
    |> tag(:integer)
    |> map(:to_integer)

  def to_integer({:integer, [r]}), do: r
  def to_integer({:integer, [{:sign, ?-}, r]}), do: -r
  def to_integer({:integer, [{:sign, ?+}, r]}), do: r

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

  dot =
    ascii_char([?.])
    |> map(:dot)

  defp dot(_), do: :dot

  def to_binary({tag, s}), do: {tag, to_string(s)}

  list =
    ignore(ascii_char([?(]))
    |> opt_ws()
    |> concat(parsec(:list_inner))
    |> opt_ws()
    |> ignore(ascii_char([?)]))
    |> tag(:list)

  vector =
    ignore(ascii_char([?[]))
    |> opt_ws()
    |> concat(parsec(:list_inner))
    |> opt_ws()
    |> ignore(ascii_char([?]]))
    |> tag(:vector)

  item_types = [identifier, integer, string, dot, list, vector]
  item = choice(item_types)

  quoted =
    ignore(ascii_char([?']))
    |> choice(item_types)
    |> unwrap_and_tag(:quoted)

  defcombinatorp(
    :item,
    choice([quoted, item])
  )

  defcombinatorp(
    :list_inner,
    optional(parsec(:item))
    |> optional(
      repeat(
        ignore(ws())
        |> opt_ws()
        |> parsec(:item)
      )
    )
  )

  #  defparsec(:toplevel, choice([opt_ws(), opt_ws() |> parsec(:list_inner) |> opt_ws()]))
  defparsec(:toplevel, choice([opt_ws() |> parsec(:list_inner) |> opt_ws(), opt_ws()]))

  def parse(code) do
    case toplevel(code) do
      {:ok, result, "", _, _, _} ->
        {:ok, result}

      {:ok, _result, rest, _, _, _} = r ->
        IO.inspect(r, label: "r")

        {:error, "Parse error near: #{rest}"}

      e ->
        {:error, :parse_error, e}
    end
  end
end
