require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  setup do
    @document = documents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:documents)
  end

  test "should create document" do
    assert_difference('Document.count') do
      post :create, document: { name: @document.name }
    end
    assert_response :success
  end

  test "should show document" do
    get :show, id: @document if @document.attachment.exists?
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @document
    assert_response :success
  end

  test "should update document" do
    patch :update, id: @document, document: { name: @document.name }
    assert_redirected_to documents_path
  end

  test "should destroy document" do
    assert_difference('Document.count', -1) do
      delete :destroy, id: @document
    end
    assert_response :success
  end
end
