require 'test_helper'

class MusicVideosControllerTest < ActionController::TestCase
  setup do
    @music_video = music_videos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:music_videos)
  end

  test "should create music_video" do
    assert_difference('MusicVideo.count') do
      post :create, music_video: { title: 'New Music Video' }
    end

    assert_response :success
  end

  test "should show music_video" do
    get :show, id: @music_video if @music_video.video.exists?
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @music_video
    assert_response :success
  end

  test "should update music_video" do
    patch :update, id: @music_video, music_video: { title: 'New Music Video' }
    assert_redirected_to music_video_path(assigns(:music_video))
  end

  test "should destroy music_video" do
    assert_difference('MusicVideo.count', -1) do
      delete :destroy, id: @music_video
    end
    assert_response :success
  end
end
