defmodule Mob.Cluster do
  def nodes, do: [Node.self()] ++ Node.list()
  def random_node, do: nodes |> Enum.random
  def random_other_node, do: Node.list |> Enum.random

  def shutdown, do: :init.stop()
end
