defmodule HEBornMigration.Web.Confirmation do

  use Ecto.Schema

  alias HEBornMigration.Web.Account
  alias HEBornMigration.Web.Token

  import Ecto.Changeset

  @type code :: String.t

  @type t :: %__MODULE__{
    code: String.t,
    id: Account.id
  }

  @primary_key false
  schema "confirmations" do
    field :code, :string,
      primary_key: true

    field :id, :integer

    belongs_to :account, Account,
      foreign_key: :id,
      define_field: false
  end

  @doc false
  def create do
    %__MODULE__{code: Token.generate()}
  end

  @spec confirm(t) ::
    Ecto.Changeset.t
  @doc """
  Propagates confirmation to account.
  """
  def confirm(struct) do
    struct
    |> cast(%{}, [])
    |> put_assoc(:account, Account.confirm(struct.account))
  end

  @spec invalid_code_changeset(code) ::
    Ecto.Changeset.t
  @doc """
  Provides a changeset with confirmation code error.
  """
  def invalid_code_changeset(code) do
    changeset =
      %__MODULE__{}
      |> Ecto.Changeset.cast(%{}, [])
      |> Ecto.Changeset.put_change(:code, code)
      |> Ecto.Changeset.add_error(:code, "is invalid")

    # phoenix only displays errors from changeset with actions
    %{changeset | action: :update}
  end

  defmodule Query do

    alias HEBornMigration.Web.Confirmation

    import Ecto.Query, only: [where: 3]

    def by_code(query \\ Confirmation, code) do
      code = String.downcase(code)

      where(query, [c], c.code == ^code)
    end
  end
end
