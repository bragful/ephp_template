defmodule EphpTemplateTest do
  use ExUnit.Case
  doctest EphpTemplate

  test "greets the world" do
    assert EphpTemplate.hello() == :world
  end
end
