# frozen_string_literal: true

require 'test_helper'

# Tests to assure surveys can be publicly filled out.
class SurveyControllerTest < ActionController::TestCase
  setup do
    @public_design = designs(:admin_public_design)
    @private_design = designs(:sections_and_variables)
  end

  test 'should get new survey with slug' do
    get :new, params: { slug: @public_design.slug }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal true, assigns(:design).publicly_available
    assert_response :success
  end

  test 'should not get new private survey' do
    assert_equal false, @private_design.publicly_available
    get :new, params: { slug: @private_design.slug }
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to about_survey_path
  end

  test 'should submit public survey' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Subject.count') do
        assert_difference('Sheet.count') do
          post :create, params: { slug: designs(:admin_public_design).slug, email: 'test@example.com' }
        end
      end
    end
    assert_not_nil assigns(:design)
    assert_equal true, assigns(:design).publicly_available
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_equal 'test@example.com', assigns(:subject).email
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).authentication_token
    assert_redirected_to about_survey_path(survey: assigns(:design).slug, a: assigns(:sheet).authentication_token)
  end

  test 'should not submit public survey without required fields' do
    assert_difference('SheetTransaction.count', 0) do
      assert_difference('Subject.count', 0) do
        assert_difference('Sheet.count', 0) do
          post :create, params: {
            slug: designs(:admin_public_design_with_required_fields).slug,
            subject_id: subjects(:external).id,
            variables: { variables(:public_autocomplete).id.to_s => '' }
          }
        end
      end
    end
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_equal ['public_autocomplete_animals can\'t be blank'], assigns(:sheet).errors[:base]
    assert_template 'new'
    assert_response :success
  end

  test 'should submit public survey and redirect to redirect_url' do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :create, params: { slug: designs(:admin_public_design_with_redirect).slug, email: 'test@example.com' }
      end
    end

    assert_not_nil assigns(:design)
    assert_equal true, assigns(:design).publicly_available
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_equal 'test@example.com', assigns(:subject).email
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).authentication_token

    assert_redirected_to 'http://localhost/survey_completed'
  end

  test 'should submit public survey without selecting a site' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Subject.count') do
        assert_difference('Sheet.count') do
          post :create, params: { slug: designs(:admin_public_design).slug, email: 'test@example.com', site_id: '' }
        end
      end
    end
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).subject
    assert_equal sites(:admin_site).id, assigns(:sheet).subject.site_id
    assert_redirected_to about_survey_path(survey: assigns(:design).slug, a: assigns(:sheet).authentication_token)
  end

  test 'should submit public survey with first site selected' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Subject.count') do
        assert_difference('Sheet.count') do
          post :create, params: {
            slug: designs(:admin_public_design).slug,
            email: 'test@example.com',
            site_id: sites(:admin_site).id
          }
        end
      end
    end
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).subject
    assert_equal sites(:admin_site).id, assigns(:sheet).subject.site_id
    assert_redirected_to about_survey_path(survey: assigns(:design).slug, a: assigns(:sheet).authentication_token)
  end

  test 'should submit public survey with second site selected' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Subject.count') do
        assert_difference('Sheet.count') do
          post :create, params: {
            slug: designs(:admin_public_design).slug,
            email: 'test@example.com',
            site_id: sites(:admin_site_two).id
          }
        end
      end
    end
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).subject
    assert_equal sites(:admin_site_two).id, assigns(:sheet).subject.site_id
    assert_redirected_to about_survey_path(survey: assigns(:design).slug, a: assigns(:sheet).authentication_token)
  end

  test 'should not submit private survey' do
    assert_difference('SheetTransaction.count', 0) do
      assert_difference('Subject.count', 0) do
        assert_difference('Sheet.count', 0) do
          post :create, params: { slug: designs(:admin_design).slug }
        end
      end
    end
    assert_nil assigns(:design)
    assert_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_nil assigns(:sheet)
    assert_equal 'This survey no longer exists.', flash[:alert]
    assert_redirected_to about_survey_path
  end

  test 'should get edit survey using authentication_token' do
    get :edit, params: {
      slug: designs(:admin_public_design).slug,
      sheet_authentication_token: sheets(:external).authentication_token
    }
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should not edit sheet survey with invalid authentication_token' do
    get :edit, params: {
      slug: designs(:admin_public_design).slug,
      sheet_authentication_token: '123'
    }
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_equal 'This survey no longer exists.', flash[:alert]
    assert_redirected_to about_survey_path(survey: assigns(:design).slug)
  end

  test 'should not edit locked sheet survey' do
    get :edit, params: {
      slug: designs(:admin_public_design).slug,
      sheet_authentication_token: sheets(:external_locked).authentication_token
    }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_equal 'This survey has been locked.', flash[:alert]
    assert_redirected_to about_survey_path(survey: assigns(:design).slug)
  end

  test 'should resubmit sheet survey using authentication_token' do
    patch :update, params: {
      slug: designs(:admin_public_design).slug,
      sheet_authentication_token: sheets(:external).authentication_token
    }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to about_survey_path(survey: assigns(:design).slug, a: assigns(:sheet).authentication_token)
  end

  test 'should not resubmit sheet survey with missing required fields' do
    patch :update, params: {
      slug: designs(:admin_public_design_with_required_fields).slug,
      sheet_authentication_token: sheets(:external_with_required_fields).authentication_token,
      variables: { variables(:public_autocomplete).id.to_s => '' }
    }
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_equal ['public_autocomplete_animals can\'t be blank'], assigns(:sheet).errors[:base]
    assert_template 'edit'
    assert_response :success
  end

  test 'should not resubmit sheet survey using invalid authentication_token' do
    patch :update, params: {
      slug: designs(:admin_public_design).slug,
      sheet_authentication_token: '123'
    }
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_equal 'This survey no longer exists.', flash[:alert]
    assert_redirected_to about_survey_path(survey: assigns(:design).slug)
  end
end
