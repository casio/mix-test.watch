mix test.watch
==============


[![Build Status](https://travis-ci.org/lpil/mix-test.watch.svg?branch=master)](https://travis-ci.org/lpil/mix-test.watch)
[![Hex version](https://img.shields.io/hexpm/v/mix_test_watch.svg "Hex version")](https://hex.pm/packages/mix_test_watch)
[![Hex downloads](https://img.shields.io/hexpm/dt/mix_test_watch.svg "Hex downloads")](https://hex.pm/packages/mix_test_watch)

Automatically run your Elixir project's tests each time you save a file.
Because TDD is awesome.


## Usage

Add it to your dependencies

```elixir
# mix.exs
def deps do
  [{:mix_test_watch, "~> 0.2", only: :dev}]
end
```

Run the mix task

```
mix test.watch
```

Start hacking :)


## Running Additional Mix Tasks

Through the mix config it is possible to run other mix tasks as well as the
test task. For example, if I wished to run the [Dogma][dogma] code style
linter after my tests I would do so like this.

[dogma]: https://github.com/lpil/dogma

```elixir
use Mix.Config

config :mix_test_watch,
  tasks: [
    "test",
    "dogma",
  ]
```

Tasks are run in the order they appear in the list, and the progression will
stop if any command returns a non-zero exit code.

All tasks are run with `MIX_ENV` set to `test`.


## Passing Arguments To Tasks

Any command line arguments passed to the `test.watch` task will be passed
through to the tasks being run. If I only want to run the tests from one file
every time I save a file I could do so with this command:

```
mix test.watch test/file/to_test.exs
```

Note that if you have configured more than one task to be run these arguments
will be passed to all the tasks run, not just the test command.


## Compatibility Notes

On Linux you may need to install `inotify-tools`.

On Windows I've no idea. If anyone knows how to use Windows and would like to
help, please get in touch.


## Licence

```
mix test.watch
Copyright © 2015-present Louis Pilfold

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
