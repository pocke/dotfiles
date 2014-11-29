# vim: set ft=ruby:

class Object
  alias_method :ivs, :instance_variable_set
  alias_method :ivg, :instance_variable_get
end
