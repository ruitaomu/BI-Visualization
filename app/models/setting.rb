class Setting < ActiveRecord::Base
  class << self
    def [](key)
      setting(key).value
    end

    def tester_attributes
      settings[:tester_attributes].split(', ')
    end

  private
    def setting(key)
      settings.detect { |setting| setting.name == key.to_s }
    end

    def settings
      @settings ||= all
    end
  end

  validate :validate_tester_attributes

  def to_s
    name
  end

private
  def validate_tester_attributes
    self.value = value.to_s.split(',').map(&:strip).reject(&:blank?).join(', ')
  end
end
