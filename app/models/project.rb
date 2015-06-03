class Project < ActiveRecord::Base
  self.inheritance_column = false
  belongs_to :customer
  has_many :videos
  has_many :testers, through: :videos

  validates :name, :customer_id, presence: true

  attr_accessor :tester_id
  scope :unarchived, -> (type) { where(type: type, archived: false)  }

  def self.types
    all.collect(&:type).uniq
  end

  def tester_id=(id)
    self.testers << Tester.find(id)
  end

  def self.project_types
      distinct.pluck(:type).compact.reject(&:empty?)
  end

  def to_s
    name
  end

  def videos_tags
    tags = []
    self.videos.each do |video|
      tags << video.tags
    end
    tags.flatten.uniq {|t| t.name}
  end

  def method_missing(method, *args, &block)
    if method =~ /^metadata_(.+)=$/
      self.metadata = metadata.merge($1 => args.first)
    elsif method =~ /^metadata_(.+)$/
      metadata[$1]
    else
      super
    end
  end

  def respond_to?(method_sym, include_private = false)
    if method_sym.to_s =~ /^metadata_(.+)$/
      true
    else
      super
    end
  end

  def save
    super
  end
end
