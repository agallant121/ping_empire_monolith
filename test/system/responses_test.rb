require "application_system_test_case"

class ResponsesTest < ApplicationSystemTestCase
  setup do
    @response = responses(:one)
  end

  test "visiting the index" do
    visit website_responses_url(@website)
    assert_selector "h1", text: "Responses"
  end

  test "should create response" do
    visit website_responses_url(@website)
    click_on "New response"

    fill_in "Error", with: @response.error
    fill_in "Response time", with: @response.response_time
    fill_in "Status code", with: @response.status_code
    fill_in "Website", with: @response.website_id
    click_on "Create Response"

    assert_text "Response was successfully created"
    click_on "Back"
  end

  test "should update Response" do
    visit website_response_url(@website, @response)
    click_on "Edit this response", match: :first

    fill_in "Error", with: @response.error
    fill_in "Response time", with: @response.response_time
    fill_in "Status code", with: @response.status_code
    fill_in "Website", with: @response.website_id
    click_on "Update Response"

    assert_text "Response was successfully updated"
    click_on "Back"
  end

  test "should destroy Response" do
    visit website_response_url(@website, @response)
    click_on "Destroy this response", match: :first

    assert_text "Response was successfully destroyed"
  end
end
