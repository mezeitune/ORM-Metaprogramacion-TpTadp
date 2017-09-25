class PersistentAttributesRepository
  #Convendrá que comparta interfaz con Hash?
end

class PersistentAttribute

  def initialize(field_type, type)
    @field_type = field_type
    @type = type
    if type.is_persistible? @value_type = Persistible.new
    else @value_type = NotPersistible.new
    end
  end

  def validations
    @validations ||= []
  end

  def validations=(validations)
    @validations = validations
  end

end

class Simple #FieldType

end

class Multiple #FieldType

end

class Persistible #ValueType

end

class NotPersistible #ValueType

end