require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @contact = contacts(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:contacts)
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create contact" do
    assert_difference('Contact.count') do
      post :create, project_id: @project, contact: { email: @contact.email, fax: @contact.fax, name: @contact.name, phone: @contact.phone, position: @contact.position, title: @contact.title }
    end

    assert_redirected_to project_contact_path(assigns(:contact).project, assigns(:contact))
  end

  test "should show contact" do
    get :show, id: @contact, project_id: @project
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contact, project_id: @project
    assert_response :success
  end

  test "should update contact" do
    put :update, id: @contact, project_id: @project, contact: { email: @contact.email, fax: @contact.fax, name: @contact.name, phone: @contact.phone, position: @contact.position, title: @contact.title }
    assert_redirected_to project_contact_path(assigns(:contact).project, assigns(:contact))
  end

  test "should destroy contact" do
    assert_difference('Contact.current.count', -1) do
      delete :destroy, id: @contact, project_id: @project
    end

    assert_redirected_to project_contacts_path
  end
end
