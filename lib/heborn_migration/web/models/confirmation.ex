defmodule HEBornMigration.Model.Confirmation do

  use Ecto.Schema

  alias HEBornMigration.Controller.Token
  alias HEBornMigration.Model.Account

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
end
