module Teamcity
  class Base
    cattr_accessor :server_url
    attr_accessor :attributes
    
    def id
      attributes[:id]
    end
    
    def initialize(attrs = {})
      self.attributes = {}.with_indifferent_access
      assign_attributes(attrs)
    end
    
    def assign_attributes(attrs)
      attrs.each do |key, value|
        attr_name = key.underscore
        if collection = self.class.collections.find { |collection| collection[:name].to_s == attr_name.to_s }
          attributes[attr_name] = collection[:klass].assign_collection(value)
        else
          attributes[attr_name] = value
        end
      end
    end
    
    def method_missing(*args)
      if args.first && val = attributes[args.first.to_s.to_sym]
        return val
      else
        super
      end
    end
    
    def fetch
      self.assign_attributes(self.class.get( self.class.server_url + self.href ))
    end
    
    def self.list_url(*args)
      if args.present?
        @list_url = args.first
      else
        @list_url
      end
    end
    
    def self.has_collection(name, klass)
      @collections = []
      @collections << { :name => name, :klass => klass }
    end
    
    def self.collections
      @collections || []
    end
    
    def self.all
      assign_collection(get(resource_list_url))
    end
    
    def self.assign_collection(hash)
      if hash.keys.size == 1
        Array.wrap(hash[hash.keys.first]).map { |attrs| new(attrs) }
      end
    end
    
    def self.get(url)
      response = RestClient.get(url, "Accept" => "application/json")
      ActiveSupport::JSON.decode response
    end
    
    def self.resource_list_url
      "#{server_url}/app/rest/#{list_url}"
    end
  end
end