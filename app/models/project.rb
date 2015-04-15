class Project < ActiveRecord::Base
  has_many :pledges, dependent: :destroy
  has_attached_file :image, styles: { 
    medium: "90x133",
    thumb: "50x50"
  },
    default_url: "placeholder.png"


	validates :name, presence: true

	validates :description, presence: true, length: { maximum: 500 }

	validates :target_pledge_amount, numericality: { greater_than: 0 }

	validates :website, format: {
    with: /https?:\/\/[\S]+\b/i,
    message: "must reference a valid URL"
  }

  validates_attachment :image,
  :content_type => { :content_type => ['image/jpeg', 'image/png'] },
  :size => { :less_than => 1.megabyte }

	def self.accepting_pledges
    where("pledging_ends_on >= ?", Time.now).order("pledging_ends_on asc")
  end
  
	def pledging_expired?
		pledging_ends_on < Date.today
	end

  def total_amount_pledged
    pledges.sum(:amount) || 0
  end

  def amount_outstanding
    target_pledge_amount - total_amount_pledged
  end

  def funded?
    amount_outstanding <= 0
  end
end
