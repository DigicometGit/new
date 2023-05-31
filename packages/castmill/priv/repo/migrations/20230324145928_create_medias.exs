defmodule Castmill.Repo.Migrations.CreateMedias do
  use Ecto.Migration

  def change do
    create table(:medias) do
      add :name, :string
      add :uri, :string
      add :size, :integer
      add :mimetype, :string

      add :organization_id, references(:organizations, column: "id", type: :uuid, on_delete: :delete_all), null: false
      add :resource_id, references(:resources, on_delete: :nilify_all), null: true

      timestamps()
    end
  end
end
