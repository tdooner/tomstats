class CreatePushNotificationSubscribers < ActiveRecord::Migration[5.0]
  create_table :push_notification_subscribers do |t|
    t.string :endpoint, null: false
    t.string :p256dh, null: false
    t.string :auth, null: false
  end
end
