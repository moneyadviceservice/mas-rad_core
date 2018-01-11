FactoryBot.define do
  factory :initial_meeting_duration do
    sequence(:name) { |n| (n * 15).to_s + ' mins' }
  end
end
