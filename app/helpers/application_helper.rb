module ApplicationHelper

  def formatSeconds(secs)
    secs = Integer(secs)
    hours = (secs / 3600) % 24
    minutes = (secs / 60) % 60
    seconds = ((secs % 60) * 1000).round(3) / 1000
    seconds = seconds.to_i
    hours = "0#{hours}" if hours < 10
    minutes = "0#{minutes}" if minutes < 10
    seconds = "0#{seconds}" if seconds < 10
    "#{hours}:#{minutes}:#{seconds}"
  end
end
