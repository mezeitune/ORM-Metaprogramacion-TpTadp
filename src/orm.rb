require 'tadb'

module Persistible
  @tabla
  @hashCampos={}

  def tabla=(unaTabla)
    @tabla = unaTabla
  end

  def save!
    1
  end

  def refresh!
    2
  end

  def forget!
    3
  end
end

class Class
  alias_method :new_sin_persistencia, :new

  def has_one(type,name)
    attr_accessor name #Va a convenir tener un hash de atributos persistibles, para no mezclarlos con los otros
    @flagPersistencia = true
  end

  def new(*args)
    nuevaInstancia = self.new_sin_persistencia(*args)#.bind(self).call
    if @flagPersistencia
      nuevaInstancia.extend(Persistible)
      nuevaInstancia.tabla = DB.table(self)
    end
    nuevaInstancia#Para que devuelva la nueva instancia
  end
end

#class Person
#  has_one String, named: :first_name
#  has_one String, named: :last_name
#  has_one Numeric, named: :age
#  has_one Boolean, named: :admin
#
#  attr_accessor :some_other_non_persistible_attribute
#end