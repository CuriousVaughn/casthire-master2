class Casting < ActiveRecord::Base
  belongs_to :user
  has_many :applicants

  def fetch_interview
    self.interview ||= "interview_#{SecureRandom.uuid[0,5]}"
  end

  def channel
    "castings_#{id}"
  end
end
