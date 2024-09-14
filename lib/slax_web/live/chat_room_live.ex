defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  alias Slax.Repo
  alias Slax.Chat.Room


  def mount(_params, _session, socket) do
    room = Room |> Repo.all() |> List.first()

    {:ok, assign(socket, :room, room)}
  end
end
