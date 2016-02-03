
require 'active_record'
##
# Extend the ability to create csv from ActiveRecord models

module ActiveRecordCsvExtension

  extend ActiveSupport::Concern

  # Take an instance and turn it into an array using the csv columns specified at the class level
  def to_csv
     self.class.csv_columns.collect {|method| try(method) || try_association_methods(method)  }
  end

  ##
  # Attempt to run a has_many count associated method by seeing if there is a chained method in the string with a '.'
  # We use this to support the has_one, belongs_to and has_many column names that we are generating while giving
  # the developer the flexibility to override those methods
  def try_association_methods(method)
    base_method = method
    chained_method = method.scan(/\.\w{1,}/).try(:first)
    return nil unless chained_method
    base_method.gsub!(chained_method,'')
    chained_method.gsub!('.','')
    try(base_method).try(chained_method)
  end


  # add your static(class) methods here
  module ClassMethods
    
    ##
    # Array of methods that we will export out of a model object.  Also used as the header row for the CSV file
    def csv_columns
      columns = column_names + belongs_to_associations + has_one_associations + has_many_associations + optional_csv_attributes - filter_names
      columns.compact!
      columns.uniq!
      columns.flatten!
      columns
    end

    ##
    # Lets you filter out sensitive information
    def filter_names
      ['ssn', 'dob', 'password', 'cc', 'credit_card', 'cvv', 'drivers_license_number', 'drivers_license_state']
    end

    ##
    # Lets us add additional csv_columns at the model level. Override in app/moderls/order.rb, etc
    def optional_csv_attributes
      []
    end

    ##
    # Iterate over all the belongs_to associations and see if it has a name.  We don't worry about _id
    # because that by default is on the database table that ActiveRecord is interpreting
    def belongs_to_associations
      self.reflect_on_all_associations(:belongs_to).collect do |assoc|
        klass = assoc.options[:class_name].try(:constantize) || assoc.name.to_s.classify.constantize
        if klass.column_names.include?('name')
          "#{assoc.name}.name"
        end
      end
    end

    ##
    # Iterate over all the has_one associations and see if the object has a name attribute else print out
    # the id
    def has_one_associations
      self.reflect_on_all_associations(:has_one).collect do |assoc|
        klass = assoc.options[:class_name].try(:constantize) || assoc.name.to_s.classify.constantize
        if klass.column_names.include?('name')
          "#{assoc.name}.name"
        else
          "#{assoc.name}.id"
        end
      end
    end

    ##
    # count all the has_many associations methods
    def has_many_associations
      self.reflect_on_all_associations(:has_many).collect {|assoc| "#{assoc.name}.count"}
    end

  end
end

# include the extension 
ActiveRecord::Base.send(:include, ActiveRecordCsvExtension)