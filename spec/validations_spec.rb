require 'rspec'
require_relative '../src/orm'

class Grade
  has_one Numeric, named: :value, default: 0
end

class Student
  has_one String, named: :full_name, default: '', no_blank: true
  has_one Numeric, named: :age, default: 0, from: 18, to: 100
  has_many Grade, named: :grades, default: [], validate: proc{ value > 2 }
end

describe 'Validations' do

  let(:pepe) do
    Student.new
  end

  after(:each) do
    TADB.class_eval("DB.clear_all")
  end

  it 'Validating a Student without giving it a name should throw an exception' do
    pepe.full_name = ''
    expect{pepe.validate!}.to raise_error ('No coincide con lo esperado por no blank')
  end

  it 'Validating a Student whose age is lower than the minimum should throw an exception' do
    pepe.full_name = 'Jose Perez'
    pepe.age = 0
    expect{pepe.validate!}.to raise_error ('No coincide con lo esperado por from')
  end

  it 'Validating a Student whose age is higher than the maximum should throw an exception' do
    pepe.full_name = 'Jose Perez'
    pepe.age = 101
    expect{pepe.validate!}.to raise_error ('No coincide con lo esperado por to')
  end

  it 'Validating a Student with an attribute that does not verify its validation block should throw an exception' do
    Student.has_one Numeric, named: :peso, default: 0, validate: proc{value > 2}
    pepe.full_name = 'Jose Perez'
    pepe.age = 20
    expect{pepe.validate!}.to raise_error ('No coincide con lo esperado por validate')
    Student.has_one Numeric, named: :peso, default: 0 #EL ATRIBUTO SE MANTIENE ENTRE TESTS (!!!)
  end

  it 'Validating a Student with an inexistent validation should throw an exception' do
    Student.has_one String, named: :domicilio, default: '', sarasa: nil
    pepe.full_name = 'Jose Perez'
    pepe.age = 20
    pepe.grades = [Grade.new]
    expect{pepe.validate!}.to raise_error ('No existe el tipo de validacion Sarasa')
    Student.has_one String, named: :domicilio, default: ''#EL ATRIBUTO SE MANTIENE ENTRE TESTS (!!!)
  end

  it 'from validation works with multiple, numeric attributes' do
    Student.has_many Numeric, named: :numeric_grades, default: [20,0,30], from: 18, to: 100
    pepe.full_name = 'Jose Perez'
    pepe.age = 20
    expect{pepe.validate!}.to raise_error ('No coincide con lo esperado por from')
    Student.has_many Numeric, named: :numeric_grades, default: []#EL ATRIBUTO SE MANTIENE ENTRE TESTS (!!!)
  end

  it 'to validation works with multiple, numeric attributes' do
    Student.has_many Numeric, named: :numeric_grades, default: [20,101,30], from: 18, to: 100
    pepe.full_name = 'Jose Perez'
    pepe.age = 20
    expect{pepe.validate!}.to raise_error ('No coincide con lo esperado por to')
    Student.has_many Numeric, named: :numeric_grades, default: []#EL ATRIBUTO SE MANTIENE ENTRE TESTS (!!!)
  end

end