defmodule K8sLivenexTest do
  use ExUnit.Case
  doctest K8sLivenex

  test "greets the world" do
    assert K8sLivenex.hello() == :world
  end
end
