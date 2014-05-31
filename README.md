# What is it?

A way to start Pry remotely and to connect to it using DRb. This allows to
access the state of the running program from anywhere.

# Installation

    gem install pry-remote

# Usage

Here's a program starting pry-remote:

```ruby
require 'pry-remote'

class Foo
  def initialize(x, y)
    binding.remote_pry
  end
end

Foo.new 10, 20
```

Running it will prompt you with a message telling you Pry is waiting for a
program to connect itself to it:

```
[pry-remote] Waiting for client on drb://localhost:9876
```

You can then connect yourself using ``pry-remote``:

```
$ pry-remote
From: example.rb @ line 7 in Foo#initialize:
     2:
     3: require 'pry-remote'
     4:
     5: class Foo
     6:   def initialize(x, y)
 =>  7:     binding.remote_pry
     8:   end
     9: end
    10:
    11: Foo.new 10, 20
pry(#<Foo:0x00000000d9b5e8>):1> self
=> #<Foo:0x1efb3b0>
pry(#<Foo:0x00000001efb3b0>):2> ls -l
Local variables: [
  [0] :_,
  [1] :_dir_,
  [2] :_file_,
  [3] :_ex_,
  [4] :_pry_,
  [5] :_out_,
  [6] :_in_,
  [7] :x,
  [8] :y
]
pry(#<Foo:0x00000001efb3b0>):3> ^D
```

# Command line options

```
[OPTIONS]
    -s, --server       Host of the server (127.0.0.1)
    -p, --port         Port of the server (9876)
    -w, --wait         Wait for the pry server to come up
    -c, --capture      Captures $stdout and $stderr from the server (true)
    -f,                Disables loading of .pryrc and its plugins, requires, and command history 
    -h, --help         Display this help message.
```

# Connecting with an external client

In order to connect with an external client, you first need to pass in the server address to the remote_pry:

```ruby
require 'pry-remote'

class Foo
  def initialize(x, y)
    binding.remote_pry(server_address, port_number)
  end
end

Foo.new 10, 20
```

...where the server address is an externally accessible ip or hostname, such as 192.168.1.x

To connect to this session, open a terminal on the client machine and enter:

```
pry-remote -s (server_ip) -p (port) -c -w
```

This will drop you into a new remote pry session.
