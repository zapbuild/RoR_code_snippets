class UserWorkExperienceSerializer < ActiveModel::Serializer
  attributes :id, :title, :employment_type, :company, :location, :start_date, :end_date, :still_working_here, :description, :user_profile_id
  # belongs_to :user_profile
end
