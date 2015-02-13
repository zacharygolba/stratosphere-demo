class Post < ActiveRecord::Base
  include Paginated

  has_attachment :image, type: :image
  
  paginated per_page: 30
  
  scope :with_image, -> {
    where.not(image_file: nil)
  }
end