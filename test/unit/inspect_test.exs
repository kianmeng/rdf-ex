defmodule RDF.InspectTest do
  use RDF.Test.Case

  alias RDF.Turtle
  alias RDF.NS.RDFS

  @test_description EX.S
                    |> RDF.type(RDFS.Class)
                    |> EX.p("foo", 42)

  @test_graph Graph.new(
                [
                  EX.S1
                  |> EX.p1(EX.O1)
                  |> EX.p2("foo", 42),
                  EX.S2
                  |> EX.p3(EX.O3)
                ],
                prefixes: [ex: EX]
              )

  describe "RDF.Description" do
    test "it includes a header" do
      {header, _} = inspect_parts(@test_description)
      assert header == "#RDF.Description<subject: #{inspect(@test_description.subject)}"
    end

    test "it encodes the description in Turtle" do
      {_, body} = inspect_parts(@test_description)

      assert body ==
               "  " <>
                 (Turtle.write_string!(@test_description, only: :triples, indent: 2)
                  |> String.trim()) <> "\n>"
    end

    test "it includes the subject when empty" do
      assert inspect(Description.new(EX.Foo)) =~
               "#RDF.Description<subject: #{inspect(RDF.iri(EX.Foo))}>"
    end

    test "it encodes the RDF-star graphs and descriptions in Turtle-star" do
      {_, triples} = inspect_parts(annotation_description(), limit: 2)
      assert triples =~ "<< <http://example.com/S> <http://example.com/P> \"Foo\" >>"
    end

    test ":limit option" do
      {_, triples} = inspect_parts(@test_description, limit: 2)

      assert triples ==
               "  " <>
                 (EX.S
                  |> EX.p("foo", 42)
                  |> Turtle.write_string!(only: :triples, indent: 2)
                  |> String.trim()) <>
                 "..\n...\n>"
    end
  end

  describe "RDF.Graph" do
    test "it includes a header with the graph name" do
      {header, _} = inspect_parts(@test_graph)
      assert header == "#RDF.Graph<name: nil"

      graph_name = RDF.iri(EX.Graph)
      {header, _} = @test_graph |> Graph.change_name(graph_name) |> inspect_parts()
      assert header == "#RDF.Graph<name: #{inspect(graph_name)}"
    end

    test "it encodes the graph in Turtle" do
      {_, body} = inspect_parts(@test_graph)

      assert body ==
               "  " <>
                 (Turtle.write_string!(@test_graph, indent: 2) |> String.trim()) <> "\n>"
    end

    test ":limit option" do
      {_, body} = inspect_parts(@test_graph, limit: 2)

      assert body ==
               "  " <>
                 (Graph.new(
                    EX.S1
                    |> EX.p1(EX.O1)
                    |> EX.p2(42),
                    prefixes: [ex: EX]
                  )
                  |> Turtle.write_string!(indent: 2)
                  |> String.trim()) <>
                 "..\n...\n>"
    end
  end

  def inspect_parts(graph, opts \\ []) do
    inspect_form = inspect(graph, opts)
    [header, body] = String.split(inspect_form, "\n", parts: 2)
    {header, body}
  end
end
