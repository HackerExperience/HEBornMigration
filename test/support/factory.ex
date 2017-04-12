defmodule HEBornMigration.Factory do

  alias HEBornMigration.Model.Account
  alias HEBornMigration.Model.Claim
  alias HEBornMigration.Repo

  @type thing :: :claim | :account

  @spec changeset(thing, map | Keyword.t) ::
    Ecto.Changeset.t
  def changeset(thing, params \\ %{}) do
    attrs =
      thing
      |> params_for()
      |> Map.merge(to_map(params))

    fabricate_changeset(thing, attrs)
  end

  @spec changeset_list(pos_integer, thing, map | Keyword.t) ::
    [Ecto.Changeset.t, ...]
  def changeset_list(n, thing, params \\ %{}) when n >= 1 do
    for _ <- 1..n,
      do: changeset(thing, params)
  end

  @spec build(thing, map | Keyword.t) ::
    Ecto.Schema.t
  def build(thing, params \\ %{}) do
    thing
    |> changeset(params)
    |> ensure_valid_changeset()
    |> Ecto.Changeset.apply_changes()
  end

  @spec build_list(pos_integer, thing, map | Keyword.t) ::
    [Ecto.Schema.t, ...]
  def build_list(n, thing, params \\ %{}) when n >= 1 do
    for _ <- 1..n,
      do: build(thing, params)
  end

  @spec insert(thing, map | Keyword.t) ::
    Ecto.Schema.t
  def insert(thing, params \\ %{}) do
    thing
    |> changeset(params)
    |> Repo.insert!()
  end

  @spec insert_list(pos_integer, thing, map | Keyword.t) ::
    [Ecto.Schema.t, ...]
  def insert_list(n, thing, params \\ %{}) when n >= 1 do
    for _ <- 1..n,
      do: insert(thing, params)
  end

  @spec params_for(thing) ::
    map
  def params_for(:claim),
    do: %{display_name: String.slice(Burette.Internet.username(), 0..14)}
  def params_for(:account) do
    %{
      claim: build(:claim),
      email: Burette.Internet.email(),
      password: Burette.Internet.password()
    }
  end

  @spec fabricate_changeset(thing, map) ::
    Ecto.Changeset.t
  defp fabricate_changeset(:claim, params) do
    Claim.create(params.display_name)
  end
  defp fabricate_changeset(:account, params) do
    Account.create(params.claim, params.email, params.password)
  end

  defp to_map(x = %{}),
    do: x
  defp to_map(x) when is_list(x),
    do: :maps.from_list(x)

  defp ensure_valid_changeset(cs = %Ecto.Changeset{valid?: true}),
    do: cs
  defp ensure_valid_changeset(cs),
    do: raise "invalid changeset generated on factory: #{inspect cs}"
end
