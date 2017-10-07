require 'rspec'
require_relative '../src/orm'

class Grade
  has_one Numeric, named: :value, default: 7, from: 4, to:9, no_blank: true
end

class Person
  attr_accessor :grades
end

describe 'Persistent attr_accessor' do

  let(:pepe){
    Person.new
  }

  after(:each) do
    TADB.class_eval("DB.clear_all")
  end

  it 'A persistent attribute defined through attr_accessor should be correctly saved and recovered' do
    pepe.grades = [Grade.new]
    pepe.save!
    persisted_pepe = Person.all_instances[0]
    expect(persisted_pepe.grades[0].value).to eq 7
  end
end