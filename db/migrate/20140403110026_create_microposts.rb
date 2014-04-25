class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end
    # We add index on both the user_id and the creation time so we can retrieve microposts for a given user in reverse order of creation. This is called a "multiple key index", meaning that Active Record uses both keys at the same time.
    add_index :microposts, [:user_id, :created_at]
  end
end
