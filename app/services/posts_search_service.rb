class PostsSearchService
  def self.search(curr_posts, query)
    # Aqui usamos un query sql, donde % significa 'cualquier cosa'
    curr_posts.where("title like '%#{query}%'")
  end
end