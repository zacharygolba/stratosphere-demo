class AddAttachmentToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :image_file, :string
    add_column :posts, :image_content_type, :string
    add_column :posts, :image_content_length, :int8
  end
end
