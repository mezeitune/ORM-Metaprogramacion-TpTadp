require 'tadb'

module Persistible

  module ClassMethods include TADB #include PROVISIONAL, VER DÓNDE GUARDAR LA TABLA (!!!)

    def all_instances
      DB.table(self).entries.map{|hashToConvert|
        nuevaInstancia=self.new #ROMPE SI INITIALIZE RECIBE PARÁMETROS (!!!)
        hashToConvert.each do |key, value|
          nuevaInstancia.send("#{key}=",value)
        end
        nuevaInstancia
      }
    end

  end

  module InstanceMethods

    def table=(table)
      @table = table
    end

    def persistent_attributes=(hash_persistent_attributes)#@persistent_attributes contiene los valores propios de la instancia
      @persistent_attributes = hash_persistent_attributes
    end

    def id=(argument) #ES BUENA IDEA TENER ESTE MÉTODO??
      @id=argument
    end

    def is_persisted?
      !@id.nil?
    end

    def save!
      if is_persisted?
        @table.delete(id)
      end
      @id=@table.insert(@persistent_attributes)
    end

    def refresh!
      if !is_persisted?
        raise 'This object does not exist in the database'
      end
      self.persistent_attributes= @table.entries.find{|entry| entry[:id] == @id}
    end

    def forget!
      @table.delete(@id)
      @id = nil
    end

  end

  def self.included(klass)
    klass.include(InstanceMethods)
    klass.extend(ClassMethods)
  end

end

class Class
  include TADB
  alias_method :new_no_persistence, :new

  def has_one(type, named:, default:)
    #@hash_campos_default contiene las claves (nombres de atributos) y los valores default que van a tener TODAS las instancias
    if !is_persistible?
      @hash_campos_default = {}
      self.include(Persistible)
    end
    @hash_campos_default[named] = default #seteo valor por default (y me guardo como clave el nombre del atributo)
  end

  def is_persistible?
    !@hash_campos_default.nil? && !@hash_campos_default.empty?
  end

  def new(*args)
    nueva_instancia = self.new_no_persistence(*args)
    if is_persistible?
      nueva_instancia.persistent_attributes= @hash_campos_default
      @hash_campos_default.keys.each do |name|
        nueva_instancia.define_singleton_method("#{name}=") {|argument| @persistent_attributes["#{name}".to_sym]=argument} #define el setter
        nueva_instancia.define_singleton_method(name) {@persistent_attributes["#{name}".to_sym]} #define el getter
      end
      nueva_instancia.table = DB.table(self) #SE PODRÍA TENER UNA ÚNICA INSTANCIA GLOBAL, EN LA CLASE (!!!)
    end
    nueva_instancia#Para que devuelva la nueva instancia
  end

  def method_missing(sym, *args, &block)#VER SI ES EL MEJOR LUGAR (!!!)
    if is_finder? sym
      define_singleton_method("find_by_#{name}") do |argument|
        self.all_instances.select{|rd| rd.send("#{name}").match(argument.to_s) }
      end
      send("find_by_#{name}")
    else
      super
    end
  end

  def respond_to_missing?(sym, include_all = false)#VER SI ES EL MEJOR LUGAR (!!!)
    is_finder? sym || super
  end

  def is_finder?(methodName) #VER SI ES EL MEJOR LUGAR (!!!)
    #name = methodName =~ /play_(\w+)/ PENDIENTE !!!
    #@hash_campos_default.key name
  end

end