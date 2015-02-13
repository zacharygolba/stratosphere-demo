class MusicVideosController < ApplicationController
  before_action :set_music_video, only: [:show, :edit, :update, :destroy]

  def index
    @music_videos = MusicVideo.with_video.page(params[:page])
    render 'music_videos/_music_videos', layout: false if request.xhr?
  end

  def show
    redirect_to music_videos_path unless @music_video.video.exists?
  end
  
  def edit
  end

  def create
    @music_video = MusicVideo.create!(music_video_params)
    render json: { id: @music_video.id }
  end

  def update
    respond_to do |format|
      if @music_video.update(music_video_params)
        format.html { redirect_to @music_video, notice: 'Music video was successfully updated.' }
        format.json { render :show, status: :ok, location: @music_video }
      else
        format.html { render :edit }
        format.json { render json: @music_video.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @music_video.destroy
    head :ok
  end

  private
    def set_music_video
      @music_video = MusicVideo.find(params[:id])
    end

    def music_video_params
      params.require(:music_video).permit(:title)
    end
end
