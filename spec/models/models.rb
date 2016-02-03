class Order < ActiveRecord::Base
	belongs_to :user
	has_one :company, through: :user
	has_one :profile, through: :user
	has_many :line_items
end

class CustomColumns < ActiveRecord::Base
	self.table_name = 'orders'

	def self.optional_csv_attributes
      ['new_method']
    end

    def new_method
    	'something'
    end
	
end

class FilterColumns < ActiveRecord::Base
	self.table_name = 'orders'

	def self.filter_names
      ['name']
    end
end

class User < ActiveRecord::Base
	belongs_to :company
	belongs_to :profile
end

class LineItem < ActiveRecord::Base
	belongs_to :order
end

class Company < ActiveRecord::Base
end

class Profile < ActiveRecord::Base
end