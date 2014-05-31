module PryRemote
  class Server
    def self.run(object, host = DefaultHost, port = DefaultPort, options = {})
      new(object, host, port, options).run
    end

    def initialize(object, host = DefaultHost, port = DefaultPort, options = {})
      @host    = host
      @port    = port

      @object  = object
      @options = options

      @client = PryRemote::Client.new
      DRb.start_service uri, @client

      puts "[pry-remote] Waiting for client on #{uri}"
      @client.wait

      puts "[pry-remote] Client received, starting remote session"
    end

    # Code that has to be called for Pry-remote to work properly
    def setup
      # If client passed stdout and stderr, redirect actual messages there.
      @old_stdout, $stdout = [$stdout, @client.stdout] if @client.stdout
      @old_stderr, $stderr = [$stderr, @client.stderr] if @client.stderr

      # Before Pry starts, save the pager config.
      # We want to disable this because the pager won't do anything useful in
      # this case (it will run on the server).
      Pry.config.pager, @old_pager = false, Pry.config.pager

      # As above, but for system config
      Pry.config.system, @old_system = PryRemote::System, Pry.config.system
    end

    # Code that has to be called after setup to return to the initial state
    def teardown
      # Reset output streams if they were changed
      $stdout = @old_stdout if @old_stdout
      $stderr = @old_stderr if @old_stderr

      # Reset config
      Pry.config.pager = @old_pager

      # Reset sysem
      Pry.config.system = @old_system

      puts "[pry-remote] Remote session terminated"

      begin
        @client.kill
      rescue DRb::DRbConnError
        puts "[pry-remote] Continuing to stop service"
      ensure
        puts "[pry-remote] Ensure stop service"
        DRb.stop_service
      end
    end

    # Actually runs pry-remote
    def run
      setup

      Pry.start(@object, @options.merge(input: client.input_proxy, output: client.output))
    ensure
      teardown
    end

    # @return Object to enter into
    attr_reader :object

    # @return [PryServer::Client] Client connecting to the pry-remote server
    attr_reader :client

    # @return [String] Host of the server
    attr_reader :host

    # @return [Integer] Port of the server
    attr_reader :port

    # @return [String] URI for DRb
    def uri
      "druby://#{host}:#{port}"
    end
  end
end
