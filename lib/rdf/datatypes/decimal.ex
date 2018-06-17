defmodule RDF.Decimal do
  @moduledoc """
  `RDF.Datatype` for XSD decimal.
  """
  use RDF.Datatype, id: RDF.Datatype.NS.XSD.decimal

  alias Elixir.Decimal, as: D


  def convert(%D{coef: coef} = value, opts) when coef in ~w[qNaN sNaN inf]a,
    do: super(value, opts)

  def convert(%D{} = decimal, _),
    do: canonical_decimal(decimal)

  def convert(value, opts) when is_integer(value),
    do: value |> D.new() |> convert(opts)

  def convert(value, opts) when is_float(value),
    do: value |> D.from_float() |> convert(opts)

  def convert(value, opts) when is_binary(value) do
    if String.contains?(value, ~w[e E]) do
      super(value, opts)
    else
      case D.parse(value) do
        {:ok, decimal} -> convert(decimal, opts)
        :error         -> super(value, opts)
      end
    end
  end

  def convert(value, opts), do: super(value, opts)


  def canonical_lexical(%D{sign: sign, coef: :qNaN}),
    do: if sign == 1, do: "NaN", else: "-NaN"

  def canonical_lexical(%D{sign: sign, coef: :sNaN}),
    do: if sign == 1, do: "sNaN", else: "-sNaN"

  def canonical_lexical(%D{sign: sign, coef: :inf}),
    do: if sign == 1, do: "Infinity", else: "-Infinity"

  def canonical_lexical(%D{} = decimal),
    do: D.to_string(decimal, :normal)


  def canonical_decimal(%D{coef: 0} = decimal),
    do: %{decimal | exp: -1}

  def canonical_decimal(%D{coef: coef, exp: 0} = decimal),
    do: %{decimal | coef: coef * 10, exp: -1}

  def canonical_decimal(%D{coef: coef, exp: exp} = decimal)
       when exp > 0,
       do: canonical_decimal(%{decimal | coef: coef * 10, exp: exp - 1})

  def canonical_decimal(%D{coef: coef} = decimal)
       when Kernel.rem(coef, 10) != 0,
       do: decimal

  def canonical_decimal(%D{coef: coef, exp: exp} = decimal),
    do: canonical_decimal(%{decimal | coef: Kernel.div(coef, 10), exp: exp + 1})


  def equal_value?(left, right), do: RDF.Numeric.equal_value?(left, right)

end