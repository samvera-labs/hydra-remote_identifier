module Hydra::RemoteIdentifier
  def remote_service(string)
    namespace_for_lookup = RemoteServices
    scheme_name = string.to_s.gsub(/(?:^|_)([a-z])/) { $1.upcase }
    if namespace_for_lookup.const_defined?(scheme_name)
      namespace_for_lookup.const_get(scheme_name).new
    else
      raise NotImplementedError.new(
        "Unable to find #{self} remote_service '#{string}'. Consider creating #{self}::#{namespace_for_lookup}::#{scheme_name}"
      )
    end
  end
  module_function :remote_service

  module RemoteServices
    # For namespace
  end
end