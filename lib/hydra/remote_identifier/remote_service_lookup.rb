require File.expand_path('../remote_services', __FILE__)
module Hydra::RemoteIdentifier
  # Given a string retrieve a RemoteService class.
  # @param string [#to_s]
  # @return [RemoteService]
  def RemoteServiceLookup(string)
    namespace_for_lookup = RemoteServices
    remote_service_class_name = string.to_s.gsub(/(?:^|_)([a-z])/) { $1.upcase }
    if namespace_for_lookup.const_defined?(remote_service_class_name)
      namespace_for_lookup.const_get(remote_service_class_name)
    else
      raise NotImplementedError.new(
        "Unable to find #{self} remote_service '#{string}'. Consider creating #{namespace_for_lookup}::#{remote_service_class_name}"
      )
    end
  end
  module_function :RemoteServiceLookup
end