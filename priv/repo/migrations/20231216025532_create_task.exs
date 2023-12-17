defmodule TodoLive.Repo.Migrations.CreateTask do
  use Ecto.Migration

  def change do
    create table(:task, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :complete, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:task, [:name])
  end
end
