defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  alias Slax.Repo
  alias Slax.Chat.Room

  def mount(params, _session, socket) do
    rooms = Repo.all(Room)

    {:ok, assign(socket, hide_topic?: false,  rooms: rooms)}
  end

  def handle_event("toggle-topic", _, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end

  def handle_params(params, _session, socket) do
    room =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          Repo.get(Room, id)

        :error ->
          List.first(socket.assigns.rooms)
      end
    {:noreply, assign(socket, hide_toipic?: false, room: room)}
  end
end
