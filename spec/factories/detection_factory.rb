# The same, but using a string instead of class constant
Factory.define :detection, :class => Detection do |d|
  d.abs_call 'P'
end
