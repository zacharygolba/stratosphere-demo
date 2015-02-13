module Paginated
  extend ActiveSupport::Concern

  included do
    cattr_accessor :per_page
  end
  
  module ClassMethods
    def total_pages
      (count/per_page).ceil + 1
    end

    def page(page_number=nil)
      page = page_number.nil? ? 1 : page_number.to_i
      limit( per_page ).offset( per_page * (page - 1) )
    end

    def paginated(options={})
      self.per_page = options[:per_page] ? options[:per_page] : 15
    end
  end
end