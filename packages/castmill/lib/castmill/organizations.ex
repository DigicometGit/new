defmodule Castmill.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Castmill.Repo

  alias Castmill.Organizations.Organization
  alias Castmill.Protocol.Access

  defimpl Access, for: Organization do
    def canAccess(organization, user, _action) do
      if user == nil do
        {:error, "No user provided"}
      else
        network_admin = Repo.get_by(Castmill.Organizations.OrganizationsUsers, organization_id: organization.id, user_id: user.id)
        if network_admin !== nil do
          # TODO: check if the user has access for the action
          {:ok, true}
        else
          {:ok, false}
        end
      end
    end
  end

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end

  alias Castmill.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(organization_id) do
    query = from user in Castmill.Accounts.User,
      join: ou in Castmill.Organizations.OrganizationsUsers,
      on: user.id == ou.user_id,
      where: ou.organization_id == ^organization_id,
      select: [user, ou.role]
    Repo.all(query)
  end

  @doc """
  Returns the list of medias.

  ## Examples

      iex> list_users()
      [%Media{}, ...]

  """
  def list_medias(organization_id) do
    query = from media in Castmill.Resources.Media,
        where: media.organization_id == ^organization_id,
      select: media
    Repo.all(query)
  end

  @doc """
  Returns the list of playlists.

  ## Examples

      iex> list_users()
      [%Media{}, ...]

  """
  def list_playlists(organization_id) do
    query = from playlist in Castmill.Resources.Playlist,
        where: playlist.organization_id == ^organization_id,
      select: playlist
    Repo.all(query)
  end

  @doc """
    Update the access for a user in an organization.
  """
  def update_access(organization_id, user_id, role) do
    %Castmill.Organizations.OrganizationsUsers{role: role, user_id: user_id, organization_id: organization_id}
    |> Castmill.Repo.insert(
      on_conflict: [set: [role: role]],
      conflict_target: [:organization_id, :user_id]
    )
  end

  @doc """
    Add a user to an organization.
  """
  def add_user(organization_id, user_id, role) do
    %Castmill.Organizations.OrganizationsUsers{role: role, user_id: user_id, organization_id: organization_id}
    |> Castmill.Repo.insert()
  end

  @doc """
    Remove a user from an organization.
  """
  def remove_user(organization_id, user_id) do
    case Castmill.Repo.delete_all(
      from ou in Castmill.Organizations.OrganizationsUsers,
      where: ou.organization_id == ^organization_id and ou.user_id == ^user_id) do
      {1, nil} ->
        {:ok, "User successfully removed."}
      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
