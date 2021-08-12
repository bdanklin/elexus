defmodule NexusTest do
  use ExUnit.Case
  doctest Nexus

  test "greets the world" do
    assert Nexus.hello() == :world
  end
end
