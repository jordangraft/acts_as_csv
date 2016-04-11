# Overview

Extend default CSV behavior to Active Record models making it easier to offer CSV downloads.  Default behavior is to iterate over all ```belongs_to```, ```has_one``` and ```has_many``` associations and add methods for names and counts.

## Installation and Usage

```
gem 'acts_as_csv'
$ bundle update
```

And then for an ```Order``` model you can do the following:

```
rails c
=> Order.first.to_csv
# ['1', 'Some Name']
=> Order.csv_columns
# ['id', 'name']
```

So a build_csv method would look something like this:

```
def self.build_csv(collection)
  CSV.generate do |csv|
    csv << csv_columns
    collection.each { |record| csv << record.to_csv }
  end
end
```

## Default Associations Output Behavior

## Singluar (belongs_to and has_one)

For ```belongs_to``` and ```has_one``` associations, the ```to_csv``` instance method and ```csv_column s``` class method will check if the target model has a name attribute and will output if it exists. Otherwise it will default to outputting the ```_id``` attribute of the target model.

## Multipe (has_many)

For ```has_many``` associations, the default behavior is to add a ```count``` attribute.  This can be overridden by adding a method in the class of the model you want to ovverride.  Example below:

```
#order.rb

class Order < ActiveRecord::Base

	has_many :line_items

    def has_many_associations
      self.reflect_on_all_associations(:has_many).collect {|assoc| "#{assoc.name}_total_amount"}
    end

    def line_items_total_amount
    	line_items.sum(:amount)
    end

end

```

## Additional configuration

You can add additional columns to be outputted in the default CSV export by adding the ```optional_csv_attributes``` method to the target model:
```
class Order < ActiveRecord::Base

	# needs to return an array of strings representing method names that exist for the model
	def self.optional_csv_attributes
		['state']
	end

	def state
		return 'the state'
	end

end
```

Some columns should be filtered from output and you can create model level filters with the ```filter_names``` method:

```
class Order < ActiveRecord::Base
	
	# again it needs to return an array of strings 
	def self.filter_names
		['ssn', 'credit_card', 'password']
	end

end
```

# Angular.js, ResourceController and fully-functional downloads

Here's the ResourceController setup with an amended index method to catch the .csv format request:

```
class OrdersController < ApplicationController

  def index
    ...
    respond_to do |format|
      format.json { render :index }
      format.csv { send_data build_csv, filename: "Orders-#{Date.today}.csv" }
    end
  end

  private

    def build_csv
      CSV.generate do |csv|
        csv << Order.csv_columns
        @orders.each { |order| csv << order.to_csv }
      end
    end

end
```

## Working with Angular

You can't download files from a server using XHR requests which is what the ajax request from Angular's $http service makes.  There's tons of janky workarounds on the web but it's easiest just to do ```<a target='_sef' href='/some/path?{{ransackParams(q)}}'>``` and then let the Rails server and browser handle the file downloading without Angular in the way.

We want to offer the flexibility to download any model using Ransack and only delivers the rows that meet the Ransack criteria.  We have historically avoiding sending a get request with Ransack to the API from Angular because of the pain in Url encoding a complex JS object.  What we overlooked was the built-in functionality of the jQuery library.  So its as easy as this.

HTML
```
<a target='_sef' href='/some/path?{{ransackParams(q)}}'>
```

Angular controller
```
    $scope.ransackParams = function(q) {
        return jQuery.param( {q: q} );
    }
```



