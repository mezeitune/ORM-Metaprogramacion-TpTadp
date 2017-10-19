class To
  def self.execute(value,expected)
    if !(value<expected)
      raise "No coincide con lo esperado por to"
    end
  end
end

class From
  def self.execute(value,expected)
    if !(value>expected)
      raise "No coincide con lo esperado por from"
    end
  end
end

class No_blank
  def self.execute(value,expected)
    if (expected)
      if(value.nil? || value.eql?(''))
        raise "No coincide con lo esperado por no blank"
      end
    end
  end
end

class Validate
  def self.execute(value,bloque)
    @value = value#value es el nombre del parametro en el bloque del validate
    if(!instance_exec(&bloque))
      raise "No coincide con lo esperado por validate"
    end
  end

  def self.value
    @value
  end
end