# frozen_string_literal: true

require 'test_helper'

# Tests to assure that project editors can create contacts for projects
class ContactsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @contact = contacts(:one)
  end

  test 'should get index' do
    get :index, params: { project_id: @project }
    assert_response :success
    assert_not_nil assigns(:contacts)
  end

  test 'should not get index with invalid project' do
    get :index, params: { project_id: -1 }
    assert_nil assigns(:contacts)
    assert_redirected_to root_path
  end

  test 'should get new' do
    get :new, params: { project_id: @project }
    assert_response :success
  end

  test 'should create contact' do
    assert_difference('Contact.count') do
      post :create, params: {
        project_id: @project,
        contact: {
          name: @contact.name,
          email: @contact.email,
          fax: @contact.fax,
          phone: @contact.phone,
          position: @contact.position,
          title: @contact.title
        }
      }
    end
    assert_redirected_to project_contact_path(assigns(:contact).project, assigns(:contact))
  end

  test 'should not create contact with blank name' do
    assert_difference('Contact.count', 0) do
      post :create, params: {
        project_id: @project,
        contact: {
          name: '',
          email: @contact.email,
          fax: @contact.fax,
          phone: @contact.phone,
          position: @contact.position,
          title: @contact.title
        }
      }
    end
    assert_not_nil assigns(:contact)
    assert assigns(:contact).errors.size > 0
    assert_equal ["can't be blank"], assigns(:contact).errors[:name]
    assert_template 'new'
  end

  test 'should not create contact with invalid project' do
    assert_difference('Contact.count', 0) do
      post :create, params: {
        project_id: -1,
        contact: {
          name: @contact.name,
          email: @contact.email,
          fax: @contact.fax,
          phone: @contact.phone,
          position: @contact.position,
          title: @contact.title
        }
      }
    end
    assert_nil assigns(:contact)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test 'should show contact' do
    get :show, params: { id: @contact, project_id: @project }
    assert_not_nil assigns(:contact)
    assert_response :success
  end

  test 'should not show contact with invalid project' do
    get :show, params: { id: @contact, project_id: -1 }
    assert_nil assigns(:contact)
    assert_redirected_to root_path
  end

  test 'should get edit' do
    get :edit, params: { id: @contact, project_id: @project }
    assert_not_nil assigns(:contact)
    assert_response :success
  end

  test 'should not get edit with invalid project' do
    get :edit, params: { id: @contact, project_id: -1 }
    assert_nil assigns(:contact)
    assert_redirected_to root_path
  end

  test 'should update contact' do
    patch :update, params: {
      id: @contact, project_id: @project,
      contact: {
        name: @contact.name,
        email: @contact.email,
        fax: @contact.fax,
        phone: @contact.phone,
        position: @contact.position,
        title: @contact.title
      }
    }
    assert_redirected_to project_contact_path(assigns(:contact).project, assigns(:contact))
  end

  test 'should not update contact with blank name' do
    patch :update, params: {
      id: @contact, project_id: @project,
      contact: {
        name: '',
        email: @contact.email,
        fax: @contact.fax,
        phone: @contact.phone,
        position: @contact.position,
        title: @contact.title
      }
    }
    assert_not_nil assigns(:contact)
    assert assigns(:contact).errors.size > 0
    assert_equal ["can't be blank"], assigns(:contact).errors[:name]
    assert_template 'edit'
  end

  test 'should not update contact with invalid project' do
    patch :update, params: {
      id: @contact, project_id: -1,
      contact: {
        name: @contact.name,
        email: @contact.email,
        fax: @contact.fax,
        phone: @contact.phone,
        position: @contact.position,
        title: @contact.title
      }
    }
    assert_nil assigns(:contact)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test 'should destroy contact' do
    assert_difference('Contact.current.count', -1) do
      delete :destroy, params: { id: @contact, project_id: @project }
    end
    assert_not_nil assigns(:contact)
    assert_not_nil assigns(:project)
    assert_redirected_to project_contacts_path
  end

  test 'should not destroy contact with invalid project' do
    assert_difference('Contact.current.count', 0) do
      delete :destroy, params: { id: @contact, project_id: -1 }
    end
    assert_nil assigns(:contact)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end
end
