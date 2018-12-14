require "application_system_test_case"

class DocumentsTest < ApplicationSystemTestCase
  setup do
    @project = projects(:aes)
    @reporter = users(:aes_project_editor)
    @adverse_event = ae_adverse_events(:teamset)
    @document_docx = ae_documents(:blank_docx)
    @document_pdf = ae_documents(:blank_pdf)
    @document_png = ae_documents(:rails_png)
  end

  test "visit document index" do
    visit_login(@reporter)
    visit ae_module_documents_url(@project, @adverse_event)
    assert_selector "h1", text: "AE#8"
    screenshot("visit-ae-documents-index")
  end

  test "create a document" do
    visit_login(@reporter)
    visit new_ae_module_document_path(@project, ae_adverse_events(:reported))
    attach_file "ae_document[file]", file_fixture("rails.png"), make_visible: true
    screenshot("upload-ae-document")
    click_on "Upload document"
    assert_text "Document was successfully created"
    screenshot("upload-ae-document")
  end

  test "destroy a document" do
    visit_login(@reporter)
    visit ae_module_documents_url(@project, @adverse_event)
    screenshot("destroy-ae-document")
    # page.accept_confirm do
      # click_on "Destroy", match: :third
      page.all("[data-method=delete]")[2].click
    # end
    screenshot("destroy-ae-document")
    assert_text "Document was successfully destroyed"
  end
end
