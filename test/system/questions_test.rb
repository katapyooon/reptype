require "application_system_test_case"

class QuestionsTest < ApplicationSystemTestCase
  setup do
    @question = questions(:one)
  end

  test "visiting the index" do
    visit questions_url
    assert_selector "h1", text: "Questions"
  end

  test "should update Question" do
    visit question_url(@question)
    click_on "Edit this question", match: :first

    fill_in "Category", with: @question.category
    fill_in "Content", with: @question.content
    fill_in "Position", with: @question.position
    click_on "Update Question"

    assert_text "Question was successfully updated"
    click_on "Back"
  end

  test "should destroy Question" do
    visit question_url(@question)
    click_on "Destroy this question", match: :first

    assert_text "Question was successfully destroyed"
  end
end
