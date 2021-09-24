require 'rails_helper'

RSpec.describe "/api/v1/user_work_experiences", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Api::V1::UserWorkExperience. As you add validations to Api::V1::UserWorkExperience, be sure to
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      Api::V1::UserWorkExperience.create! valid_attributes
      get api_v1_user_work_experiences_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      user_work_experience = Api::V1::UserWorkExperience.create! valid_attributes
      get api_v1_user_work_experience_url(api_v1_user_work_experience), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Api::V1::UserWorkExperience" do
        expect {
          post api_v1_user_work_experiences_url,
               params: { user_work_experience: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Api::V1::UserWorkExperience, :count).by(1)
      end

      it "renders a JSON response with the new api/v1_user_work_experience" do
        post api_v1_user_work_experiences_url,
             params: { user_work_experience: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Api::V1::UserWorkExperience" do
        expect {
          post api_v1_user_work_experiences_url,
               params: { user_work_experience: invalid_attributes }, as: :json
        }.to change(Api::V1::UserWorkExperience, :count).by(0)
      end

      it "renders a JSON response with errors for the new api/v1_user_work_experience" do
        post api_v1_user_work_experiences_url,
             params: { user_work_experience: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json")
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested api/v1_user_work_experience" do
        user_work_experience = Api::V1::UserWorkExperience.create! valid_attributes
        patch api_v1_user_work_experience_url(api_v1_user_work_experience),
              params: { api_v1_user_work_experience: invalid_attributes }, headers: valid_headers, as: :json
        user_work_experience.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the api/v1_user_work_experience" do
        user_work_experience = Api::V1::UserWorkExperience.create! valid_attributes
        patch api_v1_user_work_experience_url(api_v1_user_work_experience),
              params: { api_v1_user_work_experience: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json")
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the api/v1_user_work_experience" do
        user_work_experience = Api::V1::UserWorkExperience.create! valid_attributes
        patch api_v1_user_work_experience_url(api_v1_user_work_experience),
              params: { api_v1_user_work_experience: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested api/v1_user_work_experience" do
      user_work_experience = Api::V1::UserWorkExperience.create! valid_attributes
      expect {
        delete api_v1_user_work_experience_url(api_v1_user_work_experience), headers: valid_headers, as: :json
      }.to change(Api::V1::UserWorkExperience, :count).by(-1)
    end
  end
end
