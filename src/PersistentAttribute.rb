require 'json'
###############VALIDATIONS
class To
  def self.execute(param1,param2)
    if !(param1<param2)
      raise "No coincide con lo esperado por to"

    end
  end
end



class From
  def self.execute(param1,param2)

    if !(param1>param2)
      raise "No coincide con lo esperado por from"

    end
  end
end


class No_blank
  def self.execute(param1,param2)
    if (param2)
      if(param1.nil?)
        raise "No coincide con lo esperado por no blank"
      end
    end
  end
end


class PersistentAttribute

  def self.simple(type)
    SimplePersistentAttribute.new(type)
  end

  def self.multiple(type)
    MultiplePersistentAttribute.new(type)
  end

  def initialize(type)
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

  def validationsAdd(validation)#recibe un hash con todas las validations
    @validations=validation
  end

  def validate_type(object)
    raise "The object #{object} is not an instance of #{@type}" if !object.is_a? @type
  end

end

class SimplePersistentAttribute < PersistentAttribute
  def save(object)
    @value_type.save(object)
  end

  def refresh(value)#value puede ser un objeto o un id
    @value_type.refresh(value, @type)
  end

  def validate(object)
    validate_type(object)
    v=validations
    @value_type.validate(object,v)
  end
end

class MultiplePersistentAttribute < PersistentAttribute
  def save(object)
    object.map{|obj| @value_type.save(obj)}.to_json
  end

  def validate(object)
    object.each do |obj|#con each también valido que sea una lista
      validate_type(obj)
      v=validations
      @value_type.validate(obj,v)
      #validators.each do |validator|
      #  instance_exec(object, &validator)
      #end
    end
  end

  def refresh(value)
    JSON::parse(value).map{|obj| @value_type.refresh(obj, @type)}
  end
end

class PersistibleValue
  def save(object)
    object.save!
  end

  def validate(object, validations)
    object.validate!
    validations.each{|name, value| Object.const_get(name.to_s.capitalize).execute(object,value)}
  end

  def refresh(id, type)
    object = type.new
    object.id= id
    object.refresh!
  end
end

class NotPersistibleValue
  def save(object)
    object
  end

  def validate(object,validations)
    #No se hace nada. No hay que cascadear las validaciones de tipos primitivos
    validations.each{|name, value| Object.const_get(name.to_s.capitalize).execute(object,value)}

  end

  def refresh(object, type)
    object
  end
end


