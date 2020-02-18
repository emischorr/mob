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

  def reset(conn, %{"id" => group}) do
    Mob.reset_metrics(group)
    conn
    #|> put_flash(:info, "Group has been reset!")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def delete(conn, %{"id" => group}) do
    Mob.remove_group(group)
    conn
    #|> put_flash(:info, "Group removed!")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
