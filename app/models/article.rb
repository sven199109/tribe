class Article < ActiveRecord::Base
  belongs_to :category
  validates :title, presence: true

  acts_as_taggable
  paginates_per Settings.paginates.per_page

  default_scope -> { order(id: :desc) }
  scope :published, -> { where(published: Settings.articles.published) }

  class << self
    def query(params)
      result = self.all
      result = result.where(category_id: params[:category_id]) if params[:category_id].present?
      result = result.where("title like ? OR body LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      result = result.joins(:tags).where("tags.name = ?", params[:tag]) if params[:tag].present?
      if params[:pub_date] 
        date = DateTime.parse(params[:pub_date].gsub(/-/, '/'))
        result = result.where("created_at BETWEEN ? AND ?", date.beginning_of_month, date.end_of_month)
      end
      result = result.offset(params[:offset].to_i) if params[:offset].present?
      result
    end
  end
end
