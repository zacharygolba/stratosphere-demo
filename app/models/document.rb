class Document < ActiveRecord::Base
  include Paginated
  
  has_attachment :attachment

  paginated per_page: 50

  scope :with_attachment, -> {
    where.not(attachment_file: nil)
  }
  
  before_save do
    if attachment_file && attachment_file_changed?
      self.name = attachment_file
    end
  end
end
