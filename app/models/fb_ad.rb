class FbAd < ApplicationRecord
  serialize :interests, Array
  # validates :uid, presence: true
  # validates :campaign_name, presence: true
  # # validates :gender, presence: true
  # validates :headline, presence: true
  # validates :ptext, presence: true
  # validates :video_url, presence: true
  # validates :thumbnail_url, presence: true
  # validates :pixel_id, presence: true
  # validates :interests, presence: true, length: { minimum: 4, too_short: ": select at least one." }
  # validates :countries, presence: true, length: { minimum: 4, too_short: ": select at least one." }
  # validate :at_least_one_interest, :at_least_one_country

  # def at_least_one_country
  #   if (JSON.parse countries).empty?
  #     errors.add(:countries, "must be one or more")
  #   end
  # end

  # def at_least_one_interest
  #   if (JSON.parse interests).empty?
  #     errors.add(:interests, "must be one or more")
  #   end
  # end

end
