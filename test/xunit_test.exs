defmodule XunitTest do
  use ExUnit.Case
  doctest Xunit

  test "greets the world" do
    assert Xunit.hello() == :world
  end
end
