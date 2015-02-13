class AddAttachmentToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :attachment_file, :string
    add_column :documents, :attachment_content_type, :string
    add_column :documents, :attachment_content_length, :int8
  end
end
