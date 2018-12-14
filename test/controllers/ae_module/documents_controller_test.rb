require "test_helper"

class AeModule::DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @reporter = users(:aes_project_editor)
    @adverse_event = ae_adverse_events(:teamset)
    @document_docx = ae_documents(:blank_docx)
    @document_pdf = ae_documents(:blank_pdf)
    @document_png = ae_documents(:rails_png)
  end

  def document_params
    {
      file: fixture_file_upload(file_fixture("blank.doc"))
    }
  end

  test "should get index" do
    login(@reporter)
    get ae_module_documents_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get new" do
    login(@reporter)
    get new_ae_module_document_url(@project, @adverse_event)
    assert_response :success
  end

  test "should create document" do
    login(@reporter)
    assert_difference("AeDocument.count") do
      post ae_module_documents_url(@project, @adverse_event), params: { ae_document: document_params }
    end
    assert_redirected_to ae_module_documents_url(@project, @adverse_event)
  end

  test "should upload multiple files" do
    login(@reporter)
    assert_difference("AeDocument.count", 2) do
      post upload_files_ae_module_documents_url(
        @project, ae_adverse_events(:reported), format: "js"
      ), params: {
        files: [
          fixture_file_upload(file_fixture("blank.pdf")),
          fixture_file_upload(file_fixture("rails.png"))
        ]
      }
    end
    assert_template "index"
    assert_response :success
  end

  test "should show docx document" do
    login(@reporter)
    get ae_module_document_url(@project, @adverse_event, @document_docx)
    assert_response :success
  end

  test "should show pdf document" do
    login(@reporter)
    get ae_module_document_url(@project, @adverse_event, @document_pdf)
    assert_response :success
  end

  test "should show png document" do
    login(@reporter)
    get ae_module_document_url(@project, @adverse_event, @document_png)
    assert_response :success
  end

  test "should download docx document" do
    login(@reporter)
    get download_ae_module_document_url(@project, @adverse_event, @document_docx)
    assert_equal File.binread(@document_docx.file.path), response.body
    assert_response :success
  end

  test "should download pdf document" do
    login(@reporter)
    get download_ae_module_document_url(@project, @adverse_event, @document_pdf)
    assert_equal File.binread(@document_pdf.file.path), response.body
    assert_response :success
  end

  test "should download png document" do
    login(@reporter)
    get download_ae_module_document_url(@project, @adverse_event, @document_png)
    assert_equal File.binread(@document_png.file.path), response.body
    assert_response :success
  end

  test "should destroy document" do
    login(@reporter)
    assert_difference("AeDocument.count", -1) do
      delete ae_module_document_url(@project, @adverse_event, ae_documents(:delete_me))
    end
    assert_redirected_to ae_module_documents_url(@project, @adverse_event)
  end
end
