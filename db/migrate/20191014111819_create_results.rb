class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.string :text
      t.string :medium
      t.date :timestamp

      t.timestamps
    end
  end
end
