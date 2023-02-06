class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.text :question, null: false
      t.text :answer, null: false
      # These are in the python version but leaving out for now
      # t.integer :ask_count, null: false
      # t.string :audio_src_url
      # t.text :context

      t.timestamps
    end

    add_index :questions, :question, unique: true
  end
end
