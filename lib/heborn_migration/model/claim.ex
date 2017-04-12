defmodule HEBornMigration.Model.Claim do

  use Ecto.Schema

  alias HEBornMigration.Controller.Token

  import Ecto.Changeset

  @type token :: String.t

  @type t :: %__MODULE__{
    token: String.t,
    display_name: String.t
  }

  @primary_key false
  schema "claims" do
    field :token, :string,
      primary_key: true

    field :display_name, :string, size: 15
  end

  @spec create(String.t) ::
    Ecto.Changeset.t
  def create(display_name),
    do: changeset(%{display_name: display_name})

  @doc false
  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, [:display_name])
    |> validate_required([:display_name])
    |> validate_change(:display_name, &validate_display_name/2)
    |> unique_constraint(:display_name)
    |> put_change(:token, Token.generate())
  end

  @spec validate_display_name(:display_name, String.t) ::
    []
    | [display_name: String.t]
  # Validates that the display_name contains just alphanumeric and `!?$%-_.`
  # characters.
  defp validate_display_name(:display_name, value) do
    is_binary(value)
    && Regex.match?(~r/^[a-zA-Z0-9][a-zA-Z0-9\!\?\$\%\-\_\.]{1,15}$/, value)
    && []
    || [display_name: "has invalid format"]
  end
end
