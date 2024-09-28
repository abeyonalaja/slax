defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view
  alias Slax.Chat

  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms()

    {:ok, assign(socket, hide_topic?: false, rooms: rooms)}
  end

  def handle_event("toggle-topic", _, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end

  def handle_params(params, _session, socket) do
    room =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          Chat.get_room!(id)

        :error ->
          Chat.get_first_room!()
      end

    messages = Chat.list_messages_in_room(room)

    {:noreply,
     assign(socket,
       hide_topic?: false,
       messages: messages,
       page_title: "#" <> room.name,
       room: room
     )}
  end

  def username(user) do
    user.email
    |> String.split("@")
    |> List.first()
    |> String.capitalize()
  end
end
