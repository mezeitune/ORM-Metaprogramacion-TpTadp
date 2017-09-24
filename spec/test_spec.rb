require 'rspec'
require_relative '../src/orm'

describe 'Simple object persistence' do

  let(:pepe){
    class Person
      has_one String, named: :first_name, default: ""
      has_one String, named: :last_name, default: ""
      has_one Numeric, named: :age, default: 0
      #has_one Boolean, named: :admin, default: nil FALTA VER TEMA DE Boolean (!!!)
      #attr_accessor :some_other_non_persistible_attribute
    end
    Person.new
  }

  after(:all) do
    Class.class_eval("DB.clear_all")
  end

  it 'A Person should understand persistence methods if Person has one persistent attribute' do
    expect(pepe).to respond_to(:save!,:refresh!,:forget!)
  end

  it 'If a Person has one persistent attribute it should have a getter and a setter' do
    expect(pepe).to respond_to(:first_name,:first_name=)
  end

  it 'If a Person has one persistent attribute with a default value its getter should return it' do
    expect(pepe.age).to eq(0)
  end

  it 'If the first_name of a Person is set as "jose", the getter should return the same name' do
    pepe.first_name= "jose"
    expect(pepe.first_name).to eq("jose")
  end

  it 'After saving a Person, its id should not be nil' do
    pepe.first_name = "raul"
    pepe.last_name = "porcheto"
    pepe.save!
    expect(pepe.is_persisted?).to be_truthy
  end

  it 'The name of a Person should return to its persisted value after refreshing' do
    pepe.first_name = "jose"
    pepe.save!
    pepe.first_name = "pepe"
    expect(pepe.first_name).to eq("pepe")
    pepe.refresh!
    expect(pepe.first_name).to eq("jose")
  end

  it 'Trying to refresh an object that was not previously saved should raise an error' do
    expect{pepe.refresh!}.to raise_error('This object does not exist in the database')
  end

  it 'After forgetting a Person, its id should be nil' do
    pepe.first_name = "arturo"
    pepe.last_name = "puig"
    pepe.save!
    expect(pepe.is_persisted?).to be_truthy
    pepe.forget!
    expect(pepe.is_persisted?).to be_falsey #EL OBJETO NO ESTÁ DESAPARECIENDO DEL REGISTRO EN DISCO (!!!)
  end
end

class Point
  has_one Numeric, named: :x, default: 0
  has_one Numeric, named: :y, default: 0
  def add(other)
    x = self.x + other.x
    y = self.y + other.y
  end
end

describe 'Recovery and Search' do

  let(:p1){
    p1 = Point.new()
    p1.x=2
    p1.y=5
    p1
  }
  let(:p2){
    p2 = Point.new()
    p2.x=1
    p2.y=3
    p2
  }
  let(:p3){
    p3 = Point.new()
    p3.x=9
    p3.y=7
    p3
  }

  after(:all) do
    Class.class_eval("DB.clear_all")
  end

  it 'If no object is saved, all_instances should return an empty list' do
    expect(Point.all_instances).to eq([])
  end

  #it 'A saved object should appear in all_instances' do
  #  p1.save!
  #  puts Point.all_instances
  #  expect(Point.all_instances.include? p1).to be_truthy
  #end

  #AGREGAR MÁS TESTS DE all_instances (!!!)

  it ':x should be a parameterless method' do
    expect(Point.is_parameterless_method? :x).to be_truthy
  end

  it ':add should not be a parameterless method' do
    expect(Point.is_parameterless_method? :add).to be_falsey
  end

  it ':find_by_x should be a finder method' do
    expect(Point.is_finder? :find_by_x).to be_truthy
  end

  it ':find_by_id should be a finder method' do
    expect(Point.is_finder? :find_by_id).to be_truthy
  end

  #it 'If p1 is saved, it should be found using find_by_id' do
  #  id = p1.save!
  #  expect(Point.find_by_id(id)[0]).to eq(p1)
  #end

  #it 'If p1 is saved, it should be found using find_by_x' do
  #  p1.save!
  #  expect(Point.find_by_x(p1.x)[0]).to eq(p1)
  #end

end