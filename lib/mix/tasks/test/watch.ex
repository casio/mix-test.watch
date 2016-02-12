defmodule Mix.Tasks.Test.Watch do
  use Mix.Task
  use GenServer

  alias MixTestWatch.Path, as: MPath

  @default_tasks ~w(test)a

  @shortdoc """
  Automatically run tests on file changes
  """
  @moduledoc """
  A task for running tests whenever source files change.
  """

  @spec run([String.t]) :: no_return

  def run(args) do
    :ok      = Application.start :fs, :permanent
    {:ok, _} = GenServer.start_link( __MODULE__, args, name: __MODULE__ )
    before_tests()
    run_tests(args)
    :timer.sleep :infinity
  end


  # Genserver callbacks

  @spec init(String.t) :: {:ok, %{ args: [String.t]}}

  def init(args) do
    :ok = :fs.subscribe
    {:ok, %{ args: args }}
  end

  @type fs_path    :: char_list
  @type fs_event   :: {:fs, :file_event}
  @type fs_details :: {fs_path, any}
  @spec handle_info({pid, fs_event, fs_details}, %{}) :: {:noreply, %{}}

  def handle_info({_pid, {:fs, :file_event}, {path, _event_types}}, %{args: args} = state) do
    path = to_string(path)
    if MPath.watching?(path) and File.regular?(path) do
      reload_path(path)
      before_tests()
      run_tests(args)
    end
    {:noreply, state}
  end

  defp before_tests do
    if Application.get_env(:mix_test_watch, :clear_screen, nil) do
      IO.write(IO.ANSI.clear() <> IO.ANSI.home())
    end
  end

  @spec run_tests([String.t]) :: :ok

  defp run_tests(args) do
    IO.puts "\nRunning tests..."
    ["loadpaths", "deps.loadpaths", "test"] |> Enum.map(&Mix.Task.reenable/1)

    # (Re-)configure the :test env (and activate its config)
    Mix.env(:test)
    Mix.Tasks.Loadconfig.run([])

    # Run all test tasks configured
    tasks |> Enum.each(&(Mix.Task.run(&1, args)))

    # TODO(casio): Really?
    # As the configuration will grow indefinitly, we cut it after each run
    # :elixir_config.put(:at_exit, [])
  end

  defp tasks do
    Application.get_env(:mix_test_watch, :tasks, @default_tasks)
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
