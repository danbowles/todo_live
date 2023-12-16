defmodule TodoLive.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task" do
    field :complate, :boolean, default: false
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :complate])
    |> validate_required([:name, :complate])
    |> unique_constraint(:name)
  end
end
