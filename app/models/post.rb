class Post < ActiveRecord::Base
  include Paginated

  has_attachment :image, type: :image
  
  paginated per_page: 30
  
  default_scope {
    order(created_at: :desc)
  }
  
  scope :with_image, -> {
    where.not(image_file: nil)
  }
end