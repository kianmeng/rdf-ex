defmodule RDF.Quad do
  @moduledoc """
  Defines a RDF Quad.

  A Quad is a plain Elixir tuple consisting of four valid RDF values for
  subject, predicate, object and a graph context.
  """

  alias RDF.{BlankNode, Statement}

  @doc """
  Creates a `RDF.Quad` with proper RDF values.

  An error is raised when the given elements are not convertible to RDF values.

  Note: The `RDF.quad` function is a shortcut to this function.

  # Examples

      iex> RDF.Quad.new("http://example.com/S", "http://example.com/p", 42, "http://example.com/Graph")
      {~I<http://example.com/S>, ~I<http://example.com/p>, RDF.literal(42), ~I<http://example.com/Graph>}
  """
  def new(subject, predicate, object, graph_context) do
    {
      Statement.convert_subject(subject),
      Statement.convert_predicate(predicate),
      Statement.convert_object(object),
      Statement.convert_graph_name(graph_context)
    }
  end

  @doc """
  Creates a `RDF.Quad` with proper RDF values.

  An error is raised when the given elements are not convertible to RDF values.

  Note: The `RDF.quad` function is a shortcut to this function.

  # Examples

      iex> RDF.Quad.new {"http://example.com/S", "http://example.com/p", 42, "http://example.com/Graph"}
      {~I<http://example.com/S>, ~I<http://example.com/p>, RDF.literal(42), ~I<http://example.com/Graph>}
  """
  def new({subject, predicate, object, graph_context}),
    do: new(subject, predicate, object, graph_context)

end
