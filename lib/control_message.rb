class ControlMessage
  attr_reader :method

  def initialize(method)
    @method = method
  end
end