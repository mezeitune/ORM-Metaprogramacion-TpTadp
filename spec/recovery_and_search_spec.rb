require 'rspec'
require_relative '../src/orm'

class Point
  has_one Numeric, named: :x, default: 0
  has_one Numeric, named: :y, default: 0
  def add(other)
    x = self.x + other.x
    y = self.y + other.y
  end
  def equal(other)
    x == other.x
    y == other.y
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
    TADB.class_eval("DB.clear_all")
  end

  it 'If no object is saved, all_instances should return an empty list' do
    expect(Point.all_instances).to eq([[]])
  end

  it 'A saved object should appear in all_instances' do
    p1.save!
    pointCopy =  (Point.all_instances).first().first
    expect(pointCopy.equal(p1)).to be_truthy
  end

  it 'If two Points are persisted, Point.all_instances gives 2 instances of Point class' do
    p1.save!
    p2.save!
    expect((Point.all_instances).first().size).to eq(2)
  end

  it 'If two Points are persisted, their information is correctly persisted' do
    p1.save!
    p2.save!
    p1Copy = (Point.all_instances).first()[0] # Point.find_by_id(p1.id)
    p2Copy = (Point.all_instances).first()[1] # Point.find_by_id(p2.id)
    expect(p1Copy.equal(p1) && p2Copy.equal(p2)).to be_truthy
  end

  it 'If no Dog instance is persisted and all_instances message is send to Dog class, then it throws NoMethodError' do
    class Dog
      owner = "Someone"
    end
    expect{Dog.all_instances}.to raise_error NoMethodError
  end

  it 'all_instances returns the correct quantity after a save and a forget' do
    p1.save!
    quantity_after_save = Point.all_instances().first().size
    p1.forget!
    quantity_after_forget = Point.all_instances().first().size
    expect(quantity_after_save == 1 && quantity_after_forget == 0).to be_truthy
  end

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