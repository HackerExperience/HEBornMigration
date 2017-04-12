defmodule HEBornMigration.Repo.Migrations.RenameHEBorningToClaims do
  use Ecto.Migration

  def change do
    rename table(:heborning_users), to: table(:claims)
    rename table(:heborning_users_display_name_index), to: table(:claims_display_name_index)
  end
end
