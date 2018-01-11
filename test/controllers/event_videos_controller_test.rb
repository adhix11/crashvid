require 'test_helper'

class EventVideosControllerTest < ActionController::TestCase
  setup do
    @event_video = event_videos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_videos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_video" do
    assert_difference('EventVideo.count') do
      post :create, event_video: { location: @event_video.location, name: @event_video.name }
    end

    assert_redirected_to event_video_path(assigns(:event_video))
  end

  test "should show event_video" do
    get :show, id: @event_video
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_video
    assert_response :success
  end

  test "should update event_video" do
    patch :update, id: @event_video, event_video: { location: @event_video.location, name: @event_video.name }
    assert_redirected_to event_video_path(assigns(:event_video))
  end

  test "should destroy event_video" do
    assert_difference('EventVideo.count', -1) do
      delete :destroy, id: @event_video
    end

    assert_redirected_to event_videos_path
  end
end
