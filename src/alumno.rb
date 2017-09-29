require_relative "../src/orm"
class Persona

end


class Alumno
  has_one String,named: :nombre, default:""
  has_one Grade, named: :nota, default: Grade.new
end

class Grade
  has_one Numeric, named: :value, default: 0
end