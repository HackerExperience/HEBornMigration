defmodule HEBornMigration.Web.Claim do

  use Ecto.Schema

  alias HEBornMigration.Web.TokenController

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

  @spec format_error(Ecto.Changeset.t) ::
    %{atom => [String.t]}
  @doc """
  Formats changeset errors
  """
  def format_error(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @doc false
  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, [:display_name])
    |> validate_required([:display_name])
    |> validate_change(:display_name, &validate_display_name/2)
    |> unique_constraint(:display_name)
    |> put_change(:token, TokenController.generate())
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
