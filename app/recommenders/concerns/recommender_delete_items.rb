module RecommenderDeleteItems
  def delete_items
    all_items.each do |i|
      delete_item!(i)
    end
  end
end
