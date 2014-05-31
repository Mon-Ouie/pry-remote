# What is it?

A way to start Pry remotely and to connect to it using DRb. This allows to
access the state of the running program from anywhere.

# Installation

    gem install pry-remote

# Usage

Here's a program starting pry-remote:

    require 'pry-remote'

    class Foo
      def initialize(x, y)
        binding.remote_pry
      end
    end

    Foo.new 10, 20

Running it will prompt you with a message telling you Pry is waiting for a
program to connect itself to it:

     [pry-remote] Waiting for client on drb://localhost:9876

You can then connect yourself using ``pry-remote``:

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

