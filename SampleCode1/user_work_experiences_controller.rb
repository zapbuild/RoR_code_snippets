module Api::V1
  class UserWorkExperiencesController < ApplicationController
    before_action :user_work_experience, only: [:show, :update, :destroy]
    before_action :authenticate_user! ,except: [:show,:index]
    # GET /api/v1/user_work_experiences
    def index
      user_profile = User.find_by(:slug => params[:user_slug]).user_profile
      if user_profile.present?
        @user_work_experiences = user_profile.user_work_experiences.paginate(page: params[:page], per_page: PAGE_COUNT)
      end

      render_success_response({
                                  user_work_experiences: array_serializer.new(@user_work_experiences, serializer: UserWorkExperienceSerializer)},'', 200, {
                                  pagination: SerializeHelper.pagination_dict(@user_work_experiences)
                              })
    end

    # GET /api/v1/user_work_experiences/1
    def show
      render json: @user_work_experience
      render_success_response({
                                  user_work_experience: single_serializer(@user_work_experience, UserWorkExperienceSerializer)
                              })
    end

    # POST /api/v1/user_work_experiences
    def create
      if current_user.user_profile.present?
        user_profile=current_user.user_profile
      else
        user_profile=UserProfile.create(:user_id=>current_user.id)
      end
      user_work_experience_data=user_work_experience_params
      user_work_experience_data[:user_profile_id]=user_profile.id if user_profile.present?
      @user_work_experience = UserWorkExperience.new(user_work_experience_data)

      if @user_work_experience.save
        render_success_response({
                                    user_work_experience: single_serializer(@user_work_experience, UserWorkExperienceSerializer)
                                }, I18n.t('common.created', model: 'Work Experience'))
      else
        render_unprocessable_entity_response(@user_work_experience)
      end
    end

    # PATCH/PUT /api/v1/user_work_experiences/1
    def update
      if @user_work_experience.update(user_work_experience_params)
        render_success_response({
                                    user_work_experience: single_serializer(@user_work_experience, UserWorkExperienceSerializer)
                                }, I18n.t('common.updated', model: 'Work Experience'))
      else
        render_unprocessable_entity_response(@user_work_experience)
      end
    end

    # DELETE /api/v1/user_work_experiences/1
    def destroy
      @user_work_experience.destroy
      render_success_response({
                                  user_work_experience: single_serializer(@user_work_experience, UserWorkExperienceSerializer)
                              }, I18n.t('common.deleted', model: 'Work Experience'))
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def user_work_experience
      @user_work_experience = UserWorkExperience.find_by(:id=>params[:id])
      unless @user_work_experience.present?
        render_unprocessable_entity(I18n.t('common.not_fount', model: 'Work Experience'))
      end
    end

    # Only allow a trusted parameter "white list" through.
    def user_work_experience_params
      params.require(:user_work_experience).permit(:id, :title, :employment_type, :company, :location, :start_date, :end_date, :still_working_here, :description, :user_profile_id)
    end
  end
end
