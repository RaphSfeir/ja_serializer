defmodule <%= module %>Controller do
  use <%= base %>.Web, :controller

  alias <%= module %>
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  @type page_params :: %{ "page" : %{page: integer }}
  @type id_param :: { "id": integer }
  @type <%= singular %>_data :: %{ "id": integer, "data": %{ "type": String.t, "attributes": map}}

  @spec index(Plug.conn.t, page_params) :: Plug.Conn.t
  def index(conn, %{"page" => params}) do
    <%= plural %> = <%= alias %>
      |> order_by(asc: :id)
      |> Repo.paginate(params)

    meta_data = %{
      total_entries: <%= plural %>.total_entries,
      total_pages: <%= plural %>.total_pages
    }

    render(conn, "index.json-api", data: <%= plural %>, opts: [meta: meta_data])
  end

  @spec index(Plug.Conn.t, any) :: Plug.Conn.t
  def index(conn, _params) do
    index(conn, %{"page" => %{page: 0}})
  end

  @spec create(Plug.Conn.t, <%= singular %>_data) :: Plug.Conn.t
  def create(conn, %{"data" => data = %{"type" => <%= inspect singular %>, "attributes" => _<%= singular %>_params}}) do
    changeset = <%= alias %>.changeset(%<%= alias %>{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, <%= singular %>} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", <%= singular %>_path(conn, :show, <%= singular %>))
        |> render("show.json-api", data: <%= singular %>)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  @spec show(Plug.Conn.t, id_param) :: Plug.Conn.t
  def show(conn, %{"id" => id}) do
    <%= singular %> = Repo.get!(<%= alias %>, id)
    render(conn, "show.json-api", data: <%= singular %>)
  end

  @spec update(Plug.Conn.t, <%= singular %>_data) :: Plug.Conn.t
  def update(conn, %{"id" => id, "data" => data = %{"type" => <%= inspect singular %>, "attributes" => _<%= singular %>_params}}) do
    <%= singular %> = Repo.get!(<%= alias %>, id)
    changeset = <%= alias %>.changeset(<%= singular %>, Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, <%= singular %>} ->
        render(conn, "show.json-api", data: <%= singular %>)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  @spec delete(Plug.Conn.t, id_param) :: Plug.Conn.t
  def delete(conn, %{"id" => id}) do
    <%= singular %> = Repo.get!(<%= alias %>, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(<%= singular %>)

    send_resp(conn, :no_content, "")
  end

end
