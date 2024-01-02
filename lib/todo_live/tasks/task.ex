defmodule TodoLive.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task" do
    field :complete, :boolean, default: false
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :complete])
    |> validate_required([:name, :complete])
    |> unique_constraint(:name)
  end

  def edit_changeset(task, attrs) do
    task
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
