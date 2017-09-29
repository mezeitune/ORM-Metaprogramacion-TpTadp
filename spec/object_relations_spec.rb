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

class StudentNames
  has_many String, named: :names, default: %w[pepe, juan]
end

describe 'Object relations' do

  let(:pepe) do
    Student.new
  end

  #after(:all) do
  #  Class.class_eval("DB.clear_all")
  #end

  it 'Validating a Student with a String in a Grade attribute should throw an exception' do
    pepe.grade = 'Hola'
    expect{pepe.validate!}.to raise_error ('The object Hola is not an instance of Grade')
  end

  it 'An object with a Simple, NonPersistible attribute can be saved' do
    Grade.new.save!
  end

  it 'An object with a Simple, Persistible attribute can be saved' do
    pepe.save!
  end

  it 'An object with a Multiple, NonPersistible attribute can be saved' do
    student_names = StudentNames.new
    student_names.save!
  end
end