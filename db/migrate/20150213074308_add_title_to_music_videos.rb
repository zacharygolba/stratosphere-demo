class AddTitleToMusicVideos < ActiveRecord::Migration
  def change
    add_column :music_videos, :title, :string
  end
end