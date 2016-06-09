# frozen_string_literal: true
def notify(text)
  puts "Notification: #{text}"
  system("notify-send '#{text}'")
end

def notify_spam(text)
  loop do
    notify text
    sleep 10
  end
end

def done_segment
  notify 'Computed!'
end
