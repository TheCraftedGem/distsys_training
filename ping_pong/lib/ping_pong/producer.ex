require IEx

defmodule PingPong.Producer do
  @moduledoc """
  Sends pings to consumer processes
  """
  use GenServer

  alias PingPong.Consumer

  @initial %{current: 0}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def send_ping(server \\ __MODULE__) do
    GenServer.call(server, :send_ping)
  end

  def get_counts(server \\ __MODULE__) do
    GenServer.call(server, :get_counts)
  end

  def init(_args) do
    # TODO - Listen for node up and down events
    {:ok, @initial}
  end

  def handle_call(:send_ping, _from, data) do
    # TODO - Send a ping to all consumer processes
    GenServer.abcast(Consumer, {:ping, @initial.current+1, node()})
    {:reply, :ok, %{data | current: data.current+1}}
  end

  def handle_call(:get_counts, _from, data) do
    # TODO - Get the count from each consumer

    # %{
    #     n1 => 3,
    #     n2 => 3,
    #     Node.self() => 3,
    #   }

    {map, _} = GenServer.multi_call(Consumer, :total_pings)
    map = Map.new(map)
    {:reply, map, data}
  end

  # Don't remove me :)
  def handle_call(:flush, _, _) do
    {:reply, :ok, @initial}
  end

  def handle_info(_msg, data) do
    # TODO - Fill me in l8r
    {:noreply, data}
  end
end

