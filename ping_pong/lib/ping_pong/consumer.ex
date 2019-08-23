defmodule PingPong.Consumer do
  @moduledoc """
  Consumes pings sent from a producer process
  """
  use GenServer

  alias PingPong.Producer

  @initial %{counts: %{}}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def ping_count(server \\ __MODULE__) do
    GenServer.call(server, :get_pings)
  end

  def total_pings(server) do
    GenServer.call(server, :total_pings)
  end

  def count_for_node(server \\ __MODULE__, node) do
    counts = GenServer.call(server, :get_pings)
    counts[node]
  end

  def init(_args) do
    Process.send_after(self(), :catch_up, 400)
    {:ok, @initial}
  end

  def handle_call(:get_pings, _from, data) do
    {:reply, data.counts, data}
  end

  def handle_call(:total_pings, _from, data) do
    ping_count =
      data.counts
      |> Enum.map(fn {_, count} -> count end)
      |> Enum.sum()

    {:reply, ping_count, data}
  end

  # We need these for testing. Ignore the warning and do not remove :)
  def handle_call(:flush, _, _) do
    {:reply, :ok, @initial}
  end
  def handle_call(:crash, _from, data) do
    count = 42/0
    {:reply, :ok, @initial}
  end

  def handle_cast({:ping, index, node}, data) do
    {:noreply, put_in(data, [:counts, node], index)}
  end

  def handle_info(msg, data) do
    case msg do
      :catch_up ->
        GenServer.abcast(Producer, {:hiya, self()})
        {:noreply, data}

      _ ->
        {:noreply, data}
    end
  end
end
