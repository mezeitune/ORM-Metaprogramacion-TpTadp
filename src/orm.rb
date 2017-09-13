require 'tadb'

module Persistible

  def table=(aTable)
    @table = aTable
  end

  def persistentAttributes=(hashPersistentAttributes)#@persistentAttributes contiene los valores propios de la instancia
    @persistentAttributes = hashPersistentAttributes
  end

  def id
    @id
  end

  def save!
    @id=@table.insert(@persistentAttributes)
  end

  def refresh!
    if @id.nil?
      raise 'This object does not exist in the database'
    end
    self.persistentAttributes= @table.entries.find{|entry| entry[:id] == @id}
    end

  def forget!
    @table.delete(@id)
    @id = nil
  end
end

class Class
  include TADB
  alias_method :new_no_persistence, :new

  def has_one(type, hash)
    name = hash.values.slice!(0)
    defaultValue = hash.values.slice!(1)
    #@hashCamposDefault contiene las claves (nombres de atributos) y los valores default que van a tener TODAS las instancias
    @hashCamposDefault = {} if @hashCamposDefault.nil?
    @hashCamposDefault[name] = defaultValue #seteo valor por default (y me guardo como clave el nombre del atributo)
    @flagPersistencia = true
  end

  def new(*args)
    nuevaInstancia = self.new_no_persistence(*args)
    if @flagPersistencia
      nuevaInstancia.extend(Persistible)
      nuevaInstancia.persistentAttributes= @hashCamposDefault
      @hashCamposDefault.keys.each do |name|
        nuevaInstancia.define_singleton_method("#{name}=") {|argument| @persistentAttributes["#{name}".to_sym]=argument} #define el setter
        nuevaInstancia.define_singleton_method(name) {@persistentAttributes["#{name}".to_sym]} #define el getter
      end
      nuevaInstancia.table = DB.table(self)
    end
    nuevaInstancia#Para que devuelva la nueva instancia
  end
end