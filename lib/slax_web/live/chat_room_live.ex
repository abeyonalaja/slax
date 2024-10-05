defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view
  alias Slax.{Chat, Accounts}
  alias Slax.Chat.Message
  alias SlaxWeb.OnlineUsers

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    rooms = Chat.list_joined_rooms(current_user)
    users = Accounts.list_users()

    timezone = get_connect_params(socket)["timezone"]

    if connected?(socket) do
      OnlineUsers.track(self(), current_user)
    end

    OnlineUsers.subscribe()

    socket =
      socket
      |> assign(rooms: rooms, timezone: timezone, users: users)
      |> assign(online_users: OnlineUsers.list())

    {:ok, socket}
  end

  def handle_params(params, _session, socket) do
    if socket.assigns[:room], do: Chat.unsubscribe_from_room(socket.assigns.room)

    room =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          Chat.get_room!(id)

        :error ->
          Chat.get_first_room!()
      end

    messages = Chat.list_messages_in_room(room)

    Chat.subscribe_to_room(room)

    {:noreply,
     socket
     |> assign(
       hide_topic?: false,
       joined?: Chat.joined?(room, socket.assigns.current_user),
       page_title: "#" <> room.name,
       room: room
     )
     |> stream(:messages, messages, reset: true)
     |> assign_message_form(Chat.change_message(%Message{}))
     |> push_event("scroll_messages_to_bottom", %{})}
  end

  def handle_event("toggle-topic", _, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end

  def handle_event("validate-message", %{"message" => message_params}, socket) do
    changeset = Chat.change_message(%Message{}, message_params)
    {:noreply, assign_message_form(socket, changeset)}
  end

  def handle_event("submit-message", %{"message" => message_params}, socket) do
    %{current_user: current_user, room: room} = socket.assigns


    socket =
      if Chat.joined?(room, current_user) do
        case Chat.create_message(room, message_params, current_user) do
          {:ok, message} ->
            socket
            |> stream_insert(:messages, message)
            |> assign_message_form(Chat.change_message(%Message{}))

          {:error, changeset} ->
            assign_message_form(socket, changeset)
        end
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("delete-message", %{"id" => id}, socket) do
    {:ok, message} = Chat.delete_message_by_id(id, socket.assigns.current_user)
    {:noreply, stream_delete(socket, :messages, message)}
  end

  def handle_info({:new_message, message}, socket) do
    socket =
      socket
      |> stream_insert(:messages, message)
      |> push_event("scroll_messages_to_bottom", %{})

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    online_users = OnlineUsers.update(socket.assigns.online_users, diff)

    {:noreply, assign(socket, online_users: online_users)}
  end

  def handle_info({:message_deleted, message}, socket) do
    {:noreply, stream_delete(socket, :messages, message)}
  end

  defp assign_message_form(socket, changeset) do
    assign(socket, :new_message_form, to_form(changeset))
  end

  def username(user) do
    user.email
    |> String.split("@")
    |> List.first()
    |> String.capitalize()
  end
end
