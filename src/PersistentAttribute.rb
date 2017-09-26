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
    @validations ||= []
  end

  def validations=(validations)
    @validations = validations
  end

  def type #VER SI ES NECESARIO, O SI CONVIENE CHEQUEAR EL TIPO ACÁ ADENTRO (!!!)
    @type
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
    @value_type.validate(object, @type)
  end
end

class MultiplePersistentAttribute < PersistentAttribute
  def save(object)
  end

  def validate(object)
  end

  def refresh(value)
  end
end

class PersistibleValue
  def save(object)
    object.save!
  end

  def validate(object, type)
    object.validate!
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

  def validate(object, type)
    #validators.each do |validator|
    #  instance_exec(object, &validator)
    #end
    raise "The object #{object} is not an instance of #{type}" if !object.is_a? type#SE PUEDE MEJORAR EL MENSAJE
  end

  def refresh(object, type)
    object
  end
end