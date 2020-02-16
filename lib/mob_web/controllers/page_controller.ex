defmodule MobWeb.PageController do
  use MobWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", group_names: Mob.group_names())
  end

  def create(conn, %{"group" => group}) do
    Mob.new_group(group["name"], group["url"])
    conn
    #|> put_flash(:info, "New group created!")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
