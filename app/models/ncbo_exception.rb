class NCBOException < Exception

  attr_accessor :parameters

  def initialize(message, parameters)
    super(message)
    @parameters = parameters
  end

  def to_s # :nodoc:
    "#{super} (#{parameters})"
  end

end
