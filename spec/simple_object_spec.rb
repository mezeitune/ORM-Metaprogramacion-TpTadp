require 'rspec'
require_relative '../src/orm'

describe 'Simple object persistence' do

  let(:pepe){
    class Person
      has_one String, named: :first_name, default: ""
      has_one String, named: :last_name, default: ""
      has_one Numeric, named: :age, default: 0
      #has_one Boolean, named: :admin, default: nil CÓMO PODEMOS RESOLVER LA VALIDACIÓN DE TIPOS (???)
    end
    Person.new
  }

  after(:all) do
    TADB.class_eval("DB.clear_all")
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
    expect(pepe.is_persisted?).to be_falsey
  end
end