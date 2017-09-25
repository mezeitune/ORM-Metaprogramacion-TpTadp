require 'rspec'
require_relative '../src/orm'

class Grade
  has_one Numeric, named: :value, default: 0
end

class Student
  has_one String, named: :full_name, default: 'John Doe'
  has_one Grade, named: :grade, default: Grade.new

  def promoted
    self.grade > 8
  end

  def has_last_name(last_name)
    self.full_name.split(' ')[1] === last_name
  end
end

#describe 'Object relations' do
#
#  it ':grade is the only attribute that should be persisted separately' do
#    expect(Student.new.persistible_attributes).to contain_exactly 'grade'
#  end

#end