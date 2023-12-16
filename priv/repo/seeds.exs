# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TodoLive.Repo.insert!(%TodoLive.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TodoLive.Repo

base_todos = [
  %{
    name: "Clone this repo",
    complete: true
  },
  %{
    name: "Run `mix setup`",
    complete: true
  },
  %{
    name: "Create your first task",
    complete: false
  }
]

Enum.each(
  base_todos,
  &(TodoLive.Tasks.Task.changeset(%TodoLive.Tasks.Task{}, &1) |> TodoLive.Repo.insert!())
)
