defmodule Fraction do
  defstruct a: nil, b: nil

  def new(a, b) when b < 0, do: new(-a, -b)
  def new(a, b), do: normalize(%Fraction{a: a, b: b})

  defp normalize(%Fraction{a: a, b: b}) do
    gcd = Integer.gcd(a, b)
    %Fraction{a: div(a, gcd), b: div(b, gcd)}
  end

  def value(%Fraction{a: _, b: b}) when b == 0, do: {:error, :zero_denominator}
  def value(%Fraction{a: a, b: b}), do: a / b

  def add(%Fraction{} = x, %Fraction{} = y) do
    new(x.a * y.b + y.a * x.b, x.b * y.b)
  end
end
