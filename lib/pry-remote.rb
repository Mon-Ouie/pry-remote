require 'pry'
require 'slop'
require 'drb'
require 'readline'
require 'open3'

module PryRemote
  DefaultHost = "127.0.0.1"
  DefaultPort = 9876
end

require 'cli'
require 'client'
require 'input_proxy'
require 'io_undumped_proxy'
require 'server'
require 'system'

class Object
  # Starts a remote Pry session
  #
  # @param [String]  host Host of the server
  # @param [Integer] port Port of the server
  # @param [Hash] options Options to be passed to Pry.start
  def remote_pry(host = PryRemote::DefaultHost, port = PryRemote::DefaultPort, options = {})
    PryRemote::Server.new(self, host, port, options).run
  end

  # a handy alias as many people may think the method is named after the gem
  # (pry-remote)
  alias pry_remote remote_pry
end
