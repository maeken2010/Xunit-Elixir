defmodule TestCaseTest do
  def test_running() do
    alias Xunit.WasRun

    test = WasRun.new("Xunit.WasRun.test_method")
    if test.was_run, do: raise "error"

    test = WasRun.run(test)
    unless test.was_run, do: raise "error"

    IO.puts("ok")
    :ok
  end
  def test_set_up() do
    alias Xunit.WasRun

    test = WasRun.new("Xunit.WasRun.test_method")
    test = WasRun.run(test)
    unless test.was_set_up, do: raise "error"

    IO.puts("ok")
    :ok
  end
end

defmodule Xunit.WasRun do
  defstruct name: "", was_run: false

  def new(method_name) do
    struct!(Xunit.WasRun, %{ name: method_name }) 
  end

  def run(test) do
    method_name = test.name
    { result, _ } = method_name |> Code.eval_string
    result
  end

  def test_method() do
    struct!(Xunit.WasRun, %{ was_run: true })
  end
end

defmodule Mix.Tasks.XunitTest do
  use Mix.Task

  def run(_) do
    TestCaseTest.test_running()
    TestCaseTest.test_set_up()
  end
end

