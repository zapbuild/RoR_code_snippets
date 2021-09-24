module Api::V1
  class JobPostsController < ApplicationController
    before_action :set_job_post, only: [ :update, :destroy,:save]
    before_action :authenticate_user!


    def recommendations
      skills=current_user.try(:user_profile).try(:user_skills).pluck(:name)
      jobs=JobPost.select("job_posts.*,((count(nullif(job_post_skills.skill in ('#{skills.join("','")}'), false))*100)/count(job_post_skills.*) ) as skill_matches").left_joins(:job_post_skills).having("((count(nullif(job_post_skills.skill in ('#{skills.join("','")}'), false))*100)/count(job_post_skills.*) ) > 50").order("skill_matches desc").group("job_posts.id").paginate(page: params[:page], per_page: PAGE_COUNT)
      render_success_response({
                                  job_posts: array_serializer.new(jobs, serializer: JobPostSerializer)},'', 200, {
                                  pagination: SerializeHelper.pagination_dict(jobs)
                              })
    end

    def save
      job_post_save=JobPostSave.find_or_create_by(:user_id=>current_user.id,:job_post_id=>@job_post.id)
      render_success_response({
                                  job_post: single_serializer(@job_post, JobPostSerializer)
                              }, I18n.t('common.saved', model: 'Job Post'))
    end


    # GET /job_posts
    def index
      skills=current_user.try(:user_profile).try(:user_skills).pluck(:name)
      @job_posts = JobPost.select("job_posts.*,((count(nullif(job_post_skills.skill in ('#{skills.join("','")}'), false))*100)/count(job_post_skills.*) ) as skill_matches").left_joins(:job_post_skills).group("job_posts.id").paginate(page: params[:page], per_page: PAGE_COUNT)

      render_success_response({
                                  job_posts: array_serializer.new(@job_posts, serializer: JobPostSerializer)},'', 200, {
                                  pagination: SerializeHelper.pagination_dict(@job_posts)
                              })

    end

    # GET /job_posts/slug
    def show
      skills=current_user.try(:user_profile).try(:user_skills).pluck(:name)
      @job_post = JobPost.where(:slug=>params[:slug]).select("job_posts.*,((count(nullif(job_post_skills.skill in ('#{skills.join("','")}'), false))*100)/count(job_post_skills.*) ) as skill_matches").left_joins(:job_post_skills).having("((count(nullif(job_post_skills.skill in ('#{skills.join("','")}'), false))*100)/count(job_post_skills.*) ) > 50").order("skill_matches desc").group("job_posts.id").first
      if @job_post.present?
        job_post_viewers= @job_post.job_post_viewers.find_or_create_by(:viewer_id=>current_user.id) if current_user.present? && current_user.id != @job_post.user_id
        render_success_response({
                                    job_post: single_serializer(@job_post, JobPostSerializer)
                                })
      else
        render_unprocessable_entity(I18n.t('common.not_fount', model: 'Job Post'))
      end
    end

    # POST /job_posts
    def create
      company_page=CompanyPage.find_by(:public_url=>params[:company_page_public_url])
      if company_page.present?
        job_post_data=job_post_params
        job_post_data[:user_id]=current_user.id
        job_post_data[:company_page_id]=company_page.id
        @job_post = JobPost.new(job_post_data)
          if @job_post.save
            @job_post.create_activity key: 'job_post.created', owner: current_user
            render_success_response({
                                        job_post: single_serializer(@job_post, JobPostSerializer)
                                    }, I18n.t('common.created', model: 'Job Post'))
          else
            render_unprocessable_entity_response(@job_post)
          end
      else
        render_unprocessable_entity(I18n.t('common.not_fount',model: "Company Page"),500)

      end

    end

    # PATCH/PUT /job_posts/slug
    def update
      # job_post_hashtags_ids=@job_post.job_post_hashtags.ids
      if @job_post.update(job_post_params)
        # PageHashtag.delete(job_post_hashtags_ids)
        # @job_post.create_activity key: 'job_post.updated', owner: current_user
        render_success_response({
                                    job_post: single_serializer(@job_post, JobPostSerializer)
                                }, I18n.t('common.updated', model: 'Job Post'))
      else
        render_unprocessable_entity_response(@job_post)
      end
    end

    # DELETE /job_posts/slug
    def destroy
      @job_post.destroy
      @activity = PublicActivity::Activity.where(trackable_id: @job_post.id, trackable_type: "JobPost")
      @activity.destroy_all
      render_success_response({
                                  job_post: single_serializer(@job_post, JobPostSerializer)
                              }, I18n.t('common.deleted', model: 'Job Post'))
    end

    # POST /job_posts/:job_post_slug/like_dislike
    def like_dislike
      job_post=JobPost.find_by(:slug=>params[:job_post_slug])
      if job_post.present?
        @job_post_like  = PageLike.find_by(:user_id => current_user.id, :job_post_id => job_post.id)
        @job_post_likes = PageLike.where(:job_post_id => job_post.id).paginate(page: params[:page], per_page: PAGE_COUNT)
      end
      if @job_post_like.present?
        if PageLike.destroy(@job_post_like.id)
          # job_post.create_activity key: 'job_post.liked', owner: current_user
          @activity = PublicActivity::Activity.find_by(key: 'job_post.liked',owner_id: current_user.id,trackable_id: job_post.id, trackable_type: "JobPost")
          @activity.destroy
          render_success_response({
                                      job_post_likes: array_serializer.new(@job_post_likes, serializer: JobPostLikeSerializer)},'', 200, {
                                      pagination: SerializeHelper.pagination_dict(@job_post_likes)
                                  })
        else
          render_unprocessable_entity_response(@job_post_like)
        end
      else
        @job_post_like = PageLike.new(:user_id => current_user.id, :job_post_id => job_post.id)
        if @job_post_like.save
          job_post.create_activity key: 'job_post.liked', owner: current_user
          render_success_response({
                                      job_post_likes: array_serializer.new(@job_post_likes, serializer: JobPostLikeSerializer)},'', 200, {
                                      pagination: SerializeHelper.pagination_dict(@job_post_likes)
                                  })
        else
          render_unprocessable_entity_response(@job_post_like)
        end
      end
    end

    # POST /job_posts/:job_post_slug/share
    def share
      job_post=JobPost.find_by(:slug=>params[:job_post_slug])
      if job_post.present?
        job_post.create_activity key: 'job_post.shared', owner: current_user
        @job_post_share  = PageShare.find_by(:user_id => current_user.id, :job_post_id => job_post.id)
        @job_post_shares = PageShare.where(:job_post_id => job_post.id).paginate(page: params[:page], per_page: PAGE_COUNT)
      end
      # unless @job_post_share.present?
        @job_post_share = PageShare.new(:user_id => current_user.id, :job_post_id => job_post.id)
        if @job_post_share.save
          render_success_response({
                                      job_post_shares: array_serializer.new(@job_post_shares, serializer: JobPostShareSerializer)},'', 200, {
                                      pagination: SerializeHelper.pagination_dict(@job_post_shares)
                                  })
        else
          render_unprocessable_entity_response(@job_post_share)
        end
      # else
      #   render json: @job_post_shares
      # end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_job_post
      @job_post = JobPost.find_by(:slug=>params[:slug])
      unless @job_post.present?
        render_unprocessable_entity(I18n.t('common.not_fount', model: 'Job Post'))
      end
    end

    # Only allow a trusted parameter "white list" through.
    def job_post_params
      # params.fetch(:job_post, {})
      params.require(:job_post).permit(:id, :company, :company_page_id, :title, :function, :industry, :seniority_level, :job_type, :year_of_experience, :responsibilities, :description, :slug, :user_id, job_post_skills_attributes: [:id,:job_post_id,:skill,:_destroy], job_post_locations_attributes: [:id,:job_post_id,:address,:_destroy])
    end

  end
end
