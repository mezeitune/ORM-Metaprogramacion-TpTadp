require 'json'
require_relative '../src/validations'

class PersistentAttribute

  def self.simple(type, default, validations)
    SimplePersistentAttribute.new(type,default, validations)
  end

  def self.multiple(type, default, validations)
    MultiplePersistentAttribute.new(type,default, validations)
  end

  def initialize(type, default, validations)
    @default = default
    @validations=validations
    @type = type
    if type.is_persistible?
      @value_type = PersistibleValue.new
    else
      @value_type = NotPersistibleValue.new
    end
  end

  def validations
    @validations ||= {}
  end

  def validate_type(object)
    raise "The object #{object} is not an instance of #{@type}" if !object.is_a? @type
  end

end

class SimplePersistentAttribute < PersistentAttribute
  def save(object)
    @value_type.save(object, @default)
  end

  def refresh(value)#value puede ser un objeto o un id
    @value_type.refresh(value, @type)
  end

  def validate(object)
    validate_type(object)
    @value_type.validate(object, validations)
  end
end

class MultiplePersistentAttribute < PersistentAttribute
  def save(object)
    object.map{|obj| @value_type.save(obj, @default)}.to_json
  end

  def validate(object)
    object.each do |obj|#con each también valido que sea una lista
      validate_type(obj)
      @value_type.validate(obj,validations)
    end
  end

  def refresh(value)
    JSON::parse(value).map{|obj| @value_type.refresh(obj, @type)}
  end
end

class PersistibleValue
  def save(object, default)
    object.save! || (default.save! if !default.nil?)
  end

  def validate(object, validations)
    object.validate!
  end

  def refresh(id, type)
    object = type.new
    object.id= id
    object.refresh!
  end
end

class NotPersistibleValue
  def save(object, default)
    object || default
  end

  def validate(object,validations)
    validations.each do |name, value|
      validation_class_name = name.to_s.capitalize
      raise "No existe el tipo de validacion #{validation_class_name}"if !Object.const_defined? validation_class_name
      Object.const_get(validation_class_name).execute(object,value)
    end
  end

  def refresh(object, type)
    object
  end
end