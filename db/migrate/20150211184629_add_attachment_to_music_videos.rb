class AddAttachmentToMusicVideos < ActiveRecord::Migration
  def change
    add_column :music_videos, :video_file, :string
    add_column :music_videos, :video_content_type, :string
    add_column :music_videos, :video_content_length, :int8
  end
end
