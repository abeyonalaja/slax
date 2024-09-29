defmodule SlaxWeb.MessageItem do
  use SlaxWeb, :live_component
  alias SlaxWeb.ChatRoomLive

  defp message_timestamp(message) do
    message.inserted_at
    |> Timex.format!("%-l:%M %p", :strftime)
  end
end
