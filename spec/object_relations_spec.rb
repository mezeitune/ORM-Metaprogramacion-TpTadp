require 'rspec'
require_relative '../src/orm'

class Person
  has_one String,named: :apellido,default: "un apellido"
end

class Grade
  has_one Numeric, named: :value, default: 0
end

class Student < Person
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

class Teacher
  has_many Student, named: :pupils, default: []
end

describe 'Object relations' do

  let(:pepe) do
    Student.new
  end

  after(:all) do
    TADB.class_eval("DB.clear_all")
  end

  it 'Validating a Student with a String in a Grade attribute should throw an exception' do
    pepe.grade = 'Hola'
    expect{pepe.validate!}.to raise_error ('The object Hola is not an instance of Grade')
  end


  it 'Validating a Student with a [] in a Grade attribute should throw an exception' do
    pepe.grade = []
    expect{pepe.validate!}.to raise_error ('The object [] is not an instance of Grade')
  end

  it 'Validating a Teacher with a String in a List<Student> attribute should throw an exception' do
    nico = Teacher.new
    nico.pupils = 'jeje'
    expect{nico.validate!}.to raise_error ('The object [] is not an instance of Grade')
    #Rompe, pero porque el string no entiende 'each'. SIRVE COMO VALIDACIÓN DE TIPOS? (???)
  end

  it 'Validating a Teacher with a String in a List<Student> attribute should throw an exception' do
    nico = Teacher.new
    nico.pupils = [Student.new, 'jeje']
    expect{nico.validate!}.to raise_error ('The object jeje is not an instance of Student')
  end


  it 'An object with a Simple, NonPersistible attribute can be saved' do
    grade =Grade.new
    grade.save!
    expect(grade.is_persisted?).to be_truthy #MEJOR FORMA PARA VERIFICAR QUE ESTÁ BIEN PERSISTIDO (???)
  end

  it 'An object with a Simple, Persistible attribute can be saved' do
    pepe.save!
  end


  it 'An object with a Multiple, NonPersistible attribute can be saved' do
    student_names = StudentNames.new
    student_names.save!
    expect(student_names.is_persisted?).to be_truthy
  end

  it 'An object with a Multiple, Persistible attribute can be saved' do
    mati = Student.new
    mati.full_name = 'Matias Zeitune'
    nico = Teacher.new
    nico.pupils << mati
    nico.pupils << pepe
    nico.save!
    expect(nico.is_persisted?).to be_truthy
  end

  it 'An object with a Multiple, Persistible attribute can be refreshed' do
    mati = Student.new
    mati.full_name = 'Matias Zeitune'
    original_nico = Teacher.new
    original_nico.pupils << mati
    original_nico.pupils << pepe
    original_nico.save!
    new_nico = original_nico.clone
    new_nico.refresh!
    #expect(new_nico).to be(original_nico) #HAY ALGÚN MATCHER PARA HACER UNA COMPARACIÓN "PROFUNDA" (???)
  end

end