require "test_helper"

class ResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user     = users(:test_user)
    sign_in @user

    @website  = websites(:one)      # belongs to test_user
    @response = responses(:one)     # belongs to websites(:one)
  end

  test "should get index" do
    get website_responses_url(@website)
    assert_response :success
  end

  test "should get new" do
    get new_website_response_url(@website)
    assert_response :success
  end

  test "should create response" do
    assert_difference("Response.count") do
      post website_responses_url(@website), params: {
        response: {
          status_code: 200,
          response_time: 123,
          error: ""
        }
      }
    end
    assert_redirected_to website_response_url(@website, Response.last)
  end

  test "should show response" do
    get website_response_url(@website, @response)
    assert_response :success
  end

  test "should get edit" do
    get edit_website_response_url(@website, @response)
    assert_response :success
  end

  test "should update response" do
    patch website_response_url(@website, @response), params: {
      response: { status_code: 404 }
    }
    assert_redirected_to website_response_url(@website, @response)
  end

  test "should destroy response" do
    assert_difference("Response.count", -1) do
      delete website_response_url(@website, @response)
    end
    assert_redirected_to website_responses_url(@website)
  end
end
