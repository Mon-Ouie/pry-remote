module PryRemote
  # A class to represent an input object created from DRb. This is used because
  # Pry checks for arity to know if a prompt should be passed to the object.
  #
  # @attr [#readline] input Object to proxy
  InputProxy = Struct.new :input do
    # Reads a line from the input
    def readline(prompt)
      case readline_arity
      when 1 then input.readline(prompt)
      else        input.readline
      end
    end

    def completion_proc=(val)
      input.completion_proc = val
    end

    def readline_arity
      input.method_missing(:method, :readline).arity
    rescue NameError
      0
    end
  end
end
