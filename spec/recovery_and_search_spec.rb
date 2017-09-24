require 'rspec'
require_relative '../src/orm'

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