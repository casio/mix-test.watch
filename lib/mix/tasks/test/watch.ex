defmodule Mix.Tasks.Test.Watch do
  use Mix.Task
  use GenServer

  alias MixTestWatch, as: M

  @shortdoc """
  Automatically run tests on file changes
  """
  @moduledoc """
  A task for running tests whenever source files change.
  """

  @spec run([String.t]) :: no_return

  def run(args) do
    args     = Enum.join(args, " ")
    :ok      = Application.start :fs, :permanent
    {:ok, _} = GenServer.start_link( __MODULE__, args, name: __MODULE__ )
    run_tests(args)
    :timer.sleep :infinity
  end


  # Genserver callbacks

  @spec init(String.t) :: {:ok, %{ args: String.t}}

  def init(args) do
    :ok = :fs.subscribe
    {:ok, %{ args: args }}
  end

  @type fs_path    :: char_list
  @type fs_event   :: {:fs, :file_event}
  @type fs_details :: {fs_path, any}
  @spec handle_info({pid, fs_event, fs_details}, %{}) :: {:noreply, %{}}

  def handle_info({_pid, {:fs, :file_event}, {path, [_, :modified]}}, state) do
    path = to_string(path)
    if M.Path.watching?(path) do
      reload_path(path)
      run_tests(state.args)
    end
    {:noreply, state}
  end

  def handle_info({_pid, {:fs, :file_event}, {path, [_, _evt]}}, state) do
    {:noreply, state}
  end


  @spec run_tests(String.t) :: :ok

  defp run_tests(args) do
    IO.puts "\nRunning tests..."

    ["loadpaths", "deps.loadpaths", "test"] |> Enum.map(&Mix.Task.reenable/1)

    config = Application.get_all_env(:watch)
    if Keyword.get(config, :clear_screen, nil) do
      IO.write(IO.ANSI.clear() <> IO.ANSI.home())
    end

    # Reconfigure the :test env (and activate its config)
    Mix.env(:test)
    Mix.Config.read!(Path.expand("config/test.exs"))
    |> Mix.Config.persist
    Mix.Task.run("test")
    
    # TODO(casio): Really?
    # As the configuration will grow indefinitly, we cut it after each run
    # :elixir_config.put(:at_exit, [])

    # :ok = args |> M.Command.build |> M.Command.exec
    # flush
    # :ok
  end

  @spec flush :: :ok

  defp flush do
    receive do
      _       -> flush
      after 0 -> :ok
    end
  end

  
  @spec reload_path(String.t) :: :ok

  defp reload_path(path) do
    unload_test_files()
    Code.load_file(path)
  end


  @spec unload_test_files :: :ok

  defp unload_test_files do
    project = Mix.Project.config
    test_paths = project[:test_paths] || ["test"]
    Mix.Utils.extract_files(test_paths, "*") 
    |> Enum.map(&Path.expand/1)
    |> Code.unload_files
  end
end
