class JobPost < ApplicationRecord
  has_many :job_post_skills,dependent: :destroy
  has_many :job_post_locations,dependent: :destroy
  has_many :job_post_saves
  accepts_nested_attributes_for :job_post_skills,allow_destroy: true
  accepts_nested_attributes_for :job_post_locations,allow_destroy: true
  extend FriendlyId
  friendly_id :title, use: :slugged
  def normalize_friendly_id(string)
    super[0..150]
  end

end
