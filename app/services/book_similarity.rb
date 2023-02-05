require 'matrix'

class BookSimilarity
  SECTION_SEPARATOR = "\n* "

  def initialize(book_embeddings_df)
    # book_embeddings_df is a dataframe with keys of "Title","0", "1",..."4095"
    #
    # convert this to a array of 2 element arrays
    # - the first element of the array will be the "Title", e.g. "Page 1", "Page 2", etc
    # - the second element of the array will be a 4096 element Vector suitable for doing dot products
    @book_title_to_embedding_vectors = book_embeddings_df.to_a.map do |embedding_row|
      embedding_vector = Vector.elements( embedding_row.drop(1).sort.map {|element| element.second} )
      [embedding_row[:title], embedding_vector]
    end
  end

  # Given a question embedding vector, return a string of relevant sections in the book up to the max length
  def relevant_sections(question_embedding_vector, book_pages_df)
    sorted_book_section_titles = book_titles_sorted_by_relevance(question_embedding_vector)

    content = sorted_book_section_titles.map do |title|
      book_pages_df[book_pages_df[:title] == title][:content].to_a.first
    end.join(SECTION_SEPARATOR)

    prepended_content = "#{SECTION_SEPARATOR}#{content}"

  end

  def book_titles_sorted_by_relevance(question_embedding_vector)
    book_sections_sorted_by_relevance(question_embedding_vector).map {|title, _vector| title}
  end

  def book_sections_sorted_by_relevance(question_embedding_vector)
    # loop over book_embeddings_df and compute dot product and sort
    @book_title_to_embedding_vectors.sort_by do |_title, vector|
      # Use dot product to calculate similarity. Because these vectors are normalized per OpenAI documentation
      # dot product is equivalent to cosine
      # Negate the dot product so that we are sorting from most similar to least similar, i.e. descending order
      -question_embedding_vector.inner_product(vector)
    end
  end
end