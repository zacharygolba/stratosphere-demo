class MusicVideo < ActiveRecord::Base
  include Paginated
 
  @video_styles = [
      {
          name: :thumb,
          format: :jpg,
          suffix: '-00002'
      },
      {
          name: :mp4,
          format: :mp4
      },
      {
          name: :webm,
          format: :webm
      }
  ]

  has_attachment :video, type: :video, styles: @video_styles

  paginated per_page: 30

  scope :with_video, -> {
    where.not(video_file: nil)
  }

  before_save do
    if video_file && video_file_changed?
      self.title = video_file
    end
  end
end