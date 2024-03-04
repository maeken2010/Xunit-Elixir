defmodule Xunit do
  @moduledoc """
  Documentation for `Xunit`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Xunit.hello()
      :world

  """
  def main() do
    test = WasRun.new("test_method")
    if test.was_run do
      raise "error"
    end
    test = WasRun.run(test)
    unless test.was_run do
      raise "error"
    end
  end
end

