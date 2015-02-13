class CreateMusicVideos < ActiveRecord::Migration
  def change
    create_table :music_videos do |t|

      t.timestamps null: false
    end
  end
end
