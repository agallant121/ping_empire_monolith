require "application_system_test_case"

class WebsitesTest < ApplicationSystemTestCase
  setup do
    @user = users(:test_user)
    sign_in(@user)

    @website = websites(:one)
  end

  test "visiting the index" do
    visit websites_url
    assert_selector "h1", text: "Websites"
    assert_text "New website"
    assert_text "Edit this website"
    assert_text "Destroy this website"
  end

  test "should create website" do
    visit websites_url
    click_on "New website"

    fill_in "Url", with: "https://newtest.com"
    click_on "Create Website"

    assert_text "Website was successfully created"
    click_on "Back"
  end

  test "should update Website" do
    visit website_url(@website)
    click_on "Edit this website", match: :first

    fill_in "Url", with: "https://updated.com"
    click_on "Update Website"

    assert_text "Website was successfully updated"
    click_on "Back"
  end

  test "should destroy Website" do
    visit website_url(@website)
    click_on "Destroy this website", match: :first

    assert_text "Website was successfully destroyed"
  end
end
