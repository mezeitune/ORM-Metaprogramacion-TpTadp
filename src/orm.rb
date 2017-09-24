require 'tadb'

module Persistible

  module ClassMethods
    include TADB #include PROVISIONAL, VER DÓNDE GUARDAR LA TABLA (!!!)

    def all_instances
      DB.table(self).entries.map{|hashToConvert|
        nuevaInstancia=self.new #ROMPE SI INITIALIZE RECIBE PARÁMETROS (!!!)
        hashToConvert.each do |key, value|
          nuevaInstancia.send("#{key}=",value)
        end
        nuevaInstancia
      }
    end

    def method_missing(sym, *args, &block)
      if is_finder? sym
        name = sym.to_s.split('find_by_').last.to_sym
        return all_instances.select{|rd| rd.send("#{name}").eql?(args[0]) }
        #HACE FALTA DEFINIR EL MENSAJE???
      else
        super
      end
    end

    def respond_to_missing?(sym, include_all = false)
      is_finder? sym || super
    end

    def is_finder?(method)
      (method.to_s.start_with? 'find_by_') && is_parameterless_method?(method.to_s.split('find_by_').last.to_sym)
    end

    def is_parameterless_method? (methodName)
      @attr_information.keys.include?(methodName) || (instance_method(methodName).arity==0 if method_defined? methodName)
      #Se esta obteniendo @attr_information de la clase
    end

  end

  module InstanceMethods

    def table=(table)
      @table = table
    end

    def attr_information=(hash_attr_information)
      @attr_information = hash_attr_information
    end

    def persistent_attributes=(hash_persistent_attributes)#@persistent_attributes contiene los valores propios de la instancia
      @persistent_attributes = hash_persistent_attributes
    end

    def persistent_attributes
      @persistent_attributes = {} if @persistent_attributes.nil?
      @persistent_attributes
    end

    #def persistible_attributes()#devuelve solo los atributos que se tienen que persistir por separado
    #  @persistent_attributes.select{|attr| attr.class.is_persistible?}#class??
    #end

    def id
      @id
    end

    def id=(argument)
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
      @campos_default = {}
      @attr_information = {}
      self.include(Persistible)
    end
    @campos_default[named] = default #seteo valor por default (y me guardo como clave el nombre del atributo)
    @attr_information[named] = type
  end

  def is_persistible?
    !@campos_default.nil? && !@campos_default.empty?
  end

  def new(*args)
    nueva_instancia = self.new_no_persistence(*args)
    if is_persistible?
      @campos_default.each{|key,value| nueva_instancia.persistent_attributes[key]=value }
      nueva_instancia.attr_information = @attr_information
      nueva_instancia.table = DB.table(self) #SE PODRÍA TENER UNA ÚNICA INSTANCIA GLOBAL, EN LA CLASE (!!!)
      @campos_default.keys.each do |name|
        nueva_instancia.define_singleton_method("#{name}=") {|argument| persistent_attributes["#{name}".to_sym]=argument} #define el setter
        nueva_instancia.define_singleton_method(name) {persistent_attributes["#{name}".to_sym]} #define el getter
      end
    end
    nueva_instancia#Para que devuelva la nueva instancia
  end

end