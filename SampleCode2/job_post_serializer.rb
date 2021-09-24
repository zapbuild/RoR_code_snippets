class JobPostSerializer < ActiveModel::Serializer
  attributes :id,:slug, :company_page_id, :title, :function, :industry, :seniority_level, :job_type, :year_of_experience, :responsibilities, :description, :user_id
  attribute :skill_match_percentage , if: :skill_match_percentage

  def skill_match_percentage
    self.object.try(:skill_matches)
  end
  has_many :job_post_skills
  has_many :job_post_locations
end
