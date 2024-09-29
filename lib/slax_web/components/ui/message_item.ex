defmodule SlaxWeb.MessageItem do
  use SlaxWeb, :live_component
  alias SlaxWeb.ChatRoomLive

  defp message_timestamp(message, timezone) do
    message.inserted_at
    |> Timex.Timezone.convert(Timex.Timezone.local())
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%-l:%M %p", :strftime)
  end
end
