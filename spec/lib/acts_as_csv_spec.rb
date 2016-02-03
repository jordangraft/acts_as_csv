require 'spec_helper'


describe 'ActsAsCsv' do

	let(:order)			{ Order.new(user: user) }
	let(:user)			{ User.new(name: 'some name') }
	let(:filtered)		{ FilterColumns.new }

	it 'should know its column names' do
		expect(Order.csv_columns.count).to eq(14)
	end

	it 'should know be able to filter names' do
		expect(FilterColumns.csv_columns.count).to eq(9)
		expect(FilterColumns.csv_columns.include?('name')).to eq(false)
	end

	it 'should know be able to add custom columns' do
		expect(CustomColumns.csv_columns.count).to eq(11)
	end

	it 'should be able to add a count method for has many associations' do
		expect(Order.has_many_associations).to eq(['line_items.count'])
	end

	it 'should be able to add a name method for belongs_to associations' do
		expect(Order.belongs_to_associations).to eq(['user.name'])
	end

	it 'should be able to add a name method for has_one associations' do
		expect(Order.has_one_associations.include?('company.name')).to eq(true)
	end

	it 'should be able to add an _id method for has_one associations without a name' do
		expect(Order.has_one_associations.include?('profile.id')).to eq(true)
	end

	it 'should be able to try an association method on belongs to' do
		order.line_items.new
		expect(order.try_association_methods('user.name')).to eq('some name')
	end

	it 'should be able to turn an order into a csv array' do
		expect(order.to_csv.class).to eq(Array)
	end

end