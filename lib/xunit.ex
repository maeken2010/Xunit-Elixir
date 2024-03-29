defmodule TestCaseTest do
  alias Xunit.WasRun

  def was_run_test(context) do
    test = context.test
    |> WasRun.new([&Xunit.WasRun.test_method/0])

    if test.was_run, do: raise "error"

    test = WasRun.run(test)
    unless test.was_run, do: raise "error"

    IO.puts("ok")
    :ok
  end

  def set_up_test(context) do
    setup_func = fn -> %{ hoge: "hi" } end

    test = context.test
    |> WasRun.new([&Xunit.WasRun.setup_test_method/1])
    |> WasRun.set_up(setup_func)
    |> WasRun.run()

    unless test.was_set_up, do: raise "error"

    IO.puts("ok")
    :ok
  end
end

defmodule Xunit.TestCase do
  defstruct test_func: nil, setup_func: nil

  def run(%{test_func: func, setup_func: nil} = test_case) do
    func.()
    test_case
  end

  def run(%{test_func: func, setup_func: setup} = test_case) do
    context = setup.()
    func.(context)
    test_case
  end
end

defmodule Xunit.WasRun do
  defstruct test_case: [], was_set_up: false, was_run: false

  def init() do
    %Xunit.WasRun{}
  end

  def new(was_run, func_list) do
    test_case_list = Enum.map(
      func_list,
      fn(func) -> struct!(Xunit.TestCase, %{ test_func: func }) end
    )
    struct!(was_run, %{ test_case: test_case_list }) 
  end

  def set_up(%{test_case: test_case_list} = was_run, setup_func) do
    new_test_case_list = Enum.map(
      test_case_list,
      fn(test_case) -> struct!(test_case, %{ setup_func: setup_func }) end
    )
    struct!(was_run, %{ was_set_up: true, test_case: new_test_case_list})
  end

  def run(%{test_case: test_case_list} = was_run) do
    Enum.map(
      test_case_list,
      fn(test_case) -> Xunit.TestCase.run(test_case) end
    )
    struct!(was_run, %{was_run: true})
  end

  def test_method() do
    IO.puts("Test!")
  end

  def setup_test_method(context) do
    unless context.hoge == "hi", do: raise "error"
  end

end

defmodule Mix.Tasks.XunitTest do
  use Mix.Task

  def run(_) do
    test_list = [
      &TestCaseTest.was_run_test/1,
      &TestCaseTest.set_up_test/1
    ]
    Xunit.WasRun.init()
    |> Xunit.WasRun.new(test_list)
    |> Xunit.WasRun.set_up(
      fn -> %{test: Xunit.WasRun.init()} end
    )
    |> Xunit.WasRun.run()

  end
end

