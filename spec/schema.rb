ActiveRecord::Schema.define(:version => 0) do
  create_table :posts do |t|
    t.string  :title
    t.text    :content, :formatted_content
    t.text    :excerpt, :formatted_excerpt
  end
  
  create_table :comments do |t|
    t.text    :content, :formatted_content
  end
end