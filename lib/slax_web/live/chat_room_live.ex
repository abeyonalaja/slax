defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  alias Slax.Repo
  alias Slax.Chat.Room

  def mount(_params, _session, socket) do
    room = Room |> Repo.all() |> List.first()

    {:ok, assign(socket, hide_topic?: false, room: room)}
  end

  def handle_event("toggle-topic", _, socket) do
    {:noreply, assign(socket, hide_topic?: !socket.assigns.hide_topic?)}
  end
end
