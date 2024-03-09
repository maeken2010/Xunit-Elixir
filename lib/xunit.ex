defmodule TestCaseTest do
  def was_run_test() do
    alias Xunit.WasRun

    test = WasRun.new(&Xunit.WasRun.test_method/0)
    if test.was_run, do: raise "error"

    test = WasRun.run(test)
    unless test.was_run, do: raise "error"

    IO.puts("ok")
    :ok
  end

  def set_up_test() do
    alias Xunit.WasRun

    test = WasRun.new(&Xunit.WasRun.test_method/0)
    test = WasRun.run(test)
    unless test.was_set_up, do: raise "error"

    IO.puts("ok")
    :ok
  end
end

defmodule Xunit.TestCase do
  defstruct test_func: nil

  def run(%{test_func: func} = test_case) do
    func.()
    test_case
  end
end

defmodule Xunit.WasRun do
  defstruct test_case: nil, was_set_up: false, was_run: false

  def new(func) do
    test_case = struct!(Xunit.TestCase, %{ test_func: func })
    struct!(Xunit.WasRun, %{ test_case: test_case }) 
  end

  def run(%{test_case: test_case} = was_run) do
    Xunit.TestCase.run(test_case)
    struct!(was_run, %{was_run: true, was_set_up: true})
  end

  def test_method() do
    IO.puts("Test!")
  end
end

defmodule Mix.Tasks.XunitTest do
  use Mix.Task

  def run(_) do
    Xunit.WasRun.new(&TestCaseTest.was_run_test/0)
    |> Xunit.WasRun.run()

    Xunit.WasRun.new(&TestCaseTest.set_up_test/0)
    |> Xunit.WasRun.run()
  end
end

