defmodule TodoLive.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoLive.Tasks` context.
  """

  @doc """
  Generate a unique task name.
  """
  def unique_task_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        complate: true,
        name: unique_task_name()
      })
      |> TodoLive.Tasks.create_task()

    task
  end
end
