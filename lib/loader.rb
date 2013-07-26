module Loader
  def self.load_class(prefix, name)
    class_name = "#{prefix}/#{name.underscore}"
    @loaded_classes ||= {}
    @loaded_classes[class_name] ||= begin
      require class_name
      Object.const_get(prefix.to_s.camelize).const_get(name.camelize)
    end
  end
end
