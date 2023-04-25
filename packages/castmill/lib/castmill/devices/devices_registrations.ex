defmodule Castmill.Devices.DevicesRegistrations do
  use Ecto.Schema
  import Ecto.Changeset

  schema "devices_registrations" do
    field :pincode, :string
    field :device_ip, :string
    field :hardware_id, :string
    field :user_agent, :string
    field :version, :string
    field :expires_at, :utc_datetime

    field :timezone, :string
    field :loc_lat, :string
    field :loc_long, :string

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:pincode, :hardware_id, :device_ip, :user_agent, :version, :timezone, :loc_lat, :loc_long])
    |> validate_required([:pincode, :hardware_id, :device_ip, :user_agent, :version, :timezone, :loc_lat, :loc_long])
    |> put_expire()
  end

  defp put_expire(%Ecto.Changeset{valid?: true} = changeset) do
    {:ok, expires_at} = DateTime.from_unix(:os.system_time(:seconds) + 60*60, :second)
    change(changeset, %{expires_at: expires_at})
  end

  defp put_expire(changeset), do: changeset
end
