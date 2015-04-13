class Tester < ActiveRecord::Base
  has_many :videos
  has_many :projects, through: :videos

  validates :name, presence: true

  def to_s
    name
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
