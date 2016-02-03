# Overview

Extend default CSV behavior to Active Record models making it easier to offer CSV downloads.  Default behavior is to iterate over all ```belongs_to```, ```has_one``` and ```has_many``` associations and add methods for names and counts.

## Default Associations Output Behavior

### Singluar (belongs_to and has_one)

For ```belongs_to``` and ```has_one``` associations, the ```to_csv``` instance method and ```csv_column s``` class method will check if the target model has a name attribute and will output if it exists. Otherwise it will default to outputting the ```_id``` attribute of the target model.

### Multipe (has_many)

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

# Installation
Include in your Gemfile:

```
	gem 'acts_as_csv' ~> '1.0', git: 'git@git.cratebind.com:cratebind/acts_as_csv.git'
```

# Angular.js, ResourceController and fully-functional downloads

Here's the ResourceController setup with an amended index method to catch the .csv format request:

```
class Api::ResourceController < Api::BaseController
  before_action :set_klass
  before_action :set_resource, only: [:show, :update, :destroy]

  def index
    if params[:all]
      @resources = @klass.all.accessible_by(current_ability)
    else
      build_predicate
      @q = @klass.ransack(@predicate)
      if request.format.csv?
        @resources = @q.result.accessible_by(current_ability).to_a.uniq
      else
        @resources = @q.result.accessible_by(current_ability).page(params[:page]).to_a.uniq
        build_page_count_headers(@q.result.count)
        build_cache_response(@predicate)
      end
    end
    respond_to do |format|
      format.json { render :index }
      format.csv { send_data build_csv, filename: "#{@klass.to_s}-#{Date.today.to_s}.csv" }
    end
  end

  private

    def build_csv
      CSV.generate do |csv|
        csv << @klass.csv_columns
        @resources.each { |record| csv << record.to_csv }
      end
    end

    def build_predicate
      if params[:initial] && params[:cache_key]
        terms = JSON.try(:parse, $redis.hget('cache', params[:cache_key])) rescue nil
        @predicate = terms ? terms : params[:q]
      else
        @predicate = params[:q]
        $redis.hset('cache', params[:cache_key], params[:q].to_json) rescue true if params[:cache_key]
      end
    end

    def set_resource
      @resource = @klass.accessible_by(current_ability).find(params[:id])
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



