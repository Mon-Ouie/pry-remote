require 'pry'
require 'slop'
require 'drb'
require 'readline'
require 'open3'

module PryRemote
  # A class to represent an input object created from DRb. This is used because
  # Pry checks for arity to know if a prompt should be passed to the object.
  #
  # @attr [#readline] input Object to proxy
  InputProxy = Struct.new :input do
    # Reads a line from the input
    def readline(prompt)
      input.readline(prompt)
    end
  end

  # Ensure that system (shell command) output is redirected for remote session.
  System = proc do |output, cmd, _|
    status = nil
    Open3.popen3 cmd do |stdin, stdout, stderr, wait_thr|
      stdin.close # Send EOF to the process

      until stdout.eof? and stderr.eof?
        ios = [stdout, stderr]

        if res = IO.select([stdout, stderr])
          res[0].each do |io|
            next if io.eof?
            output.write io.read_nonblock(1024)
          end
        end
      end

      status = wait_thr.value
    end

    unless status.success?
      output.puts "Error while executing command: #{cmd}"
    end
  end

  # A client is used to retrieve information from the client program.
  Client = Struct.new :input, :output, :thread, :stdout, :stderr do
    # Waits until both an input and output are set
    def wait
      sleep 0.01 until input and output and thread
    end

    # Tells the client the session is terminated
    def kill
      thread.run
    end

    # @return [InputProxy] Proxy for the input
    def input_proxy
      InputProxy.new input
    end
  end

  # Parses arguments and allows to start the client.
  class CLI
    def initialize(args = ARGV)
      params = Slop.parse args, :help => true do
        banner "#$PROGRAM_NAME [OPTIONS]"

        on :h, :host, "Host of the server (localhost)", true,
           :default => "localhost"
        on :p, :port, "Port of the server (9876)", true, :as => Integer,
           :default => 9876
        on :c, :capture, "Captures $stdout and $stderr from the server (true)",
           :default => true
      end

      @host = params[:host]
      @port = params[:port]

      @capture = params[:capture]
    end

    # @return [String] Host of the server
    attr_reader :host

    # @return [Integer] Port of the server
    attr_reader :port

    # @return [String] URI for DRb
    def uri
      "druby://#{host}:#{port}"
    end

    attr_reader :capture
    alias capture? capture

    # Connects to the server
    def run
      DRb.start_service
      client = DRbObject.new(nil, uri)

      # Passing Readline to DRb won't actually make it use our readline
      # object. Instead, it will use the server-side readilne. Therefore, we
      # create a simple proxy here.

      input = Object.new
      def input.readline(prompt)
        Readline.readline(prompt, true)
      end

      client.input  = input
      client.output = $stdout

      if capture?
        client.stdout = $stdout
        client.stderr = $stderr
      end

      client.thread = Thread.current

      sleep
      DRb.stop_service
    end
  end
end

class Object
  # Starts a remote Pry session
  #
  # @param [String]  host Host of the server
  # @param [Integer] port Port of the server
  def remote_pry(host = "localhost", port = 9876)
    uri = "druby://#{host}:#{port}"

    client = PryRemote::Client.new
    DRb.start_service uri, client

    puts "[pry-remote] Waiting for client on #{uri}"
    client.wait

    begin
      # If client passed stdout and stderr, redirect actual messages there.
      old_stdout, $stdout = if client.stdout
                              [$stdout, client.stdout]
                            else
                              [$stdout, $stdout]
                            end

      old_stderr, $stderr = if client.stderr
                              [$stderr, client.stderr]
                            else
                              [$stderr, $stderr]
                            end

      # Before Pry starts, save the pager config.
      # We want to disable this because the pager won't do anything useful in
      # this case (it will run on the server).
      Pry.config.pager, old_pager = false, Pry.config.pager

      # As above, but for system config
      Pry.config.system, old_system = PryRemote::System, Pry.config.system

      puts "[pry-remote] Client received, starting remote sesion"
      Pry.start(self, :input => client.input_proxy, :output => client.output)
    ensure
      # Reset output streams
      $stdout = old_stdout
      $stderr = old_stderr

      # Reset config
      Pry.config.pager = old_pager

      # Reset sysem
      Pry.config.system = old_system

      puts "[pry-remote] Remote sesion terminated"
      client.kill

      DRb.stop_service
    end
  end

  # a handy alias as many people may think the method is named after the gem
  # (pry-remote)
  alias pry_remote remote_pry
end
