require 'matrix'

class BookSimilarity
  MAX_SECTION_LENGTH = 800
  SECTION_SEPARATOR = "\n* "
  SECTION_SEPARATOR_TOKEN_LENGTH = 3 # Tokenizers.from_pretrained("gpt2").encode(SECTION_SEPARATOR).tokens.count

  def initialize(book_embeddings_df)
    # book_embeddings_df is a dataframe with keys of "Title","0", "1",..."4095"
    #
    # convert this to a array of 2 element arrays
    # - the first element of the array will be the "Title", e.g. "Page 1", "Page 2", etc
    # - the second element of the array will be a 4096 element Vector suitable for doing dot products
    @book_title_to_embedding_vectors = book_embeddings_df.to_a.map do |embedding_row|
      embedding_vector = Vector.elements( embedding_row.except("title").sort.map {|element| element.second} )
      [embedding_row["title"], embedding_vector]
    end
  end

  # Given a question embedding vector, return a string of relevant sections in the book up to the max length
  def relevant_sections(question_embedding_vector, book_pages_df)
    sorted_book_section_titles = book_titles_sorted_by_relevance(question_embedding_vector)

    # Pick as much relevant content as possible to stick in the prompt, up to MAX_SECTION_LENGTH
    # One caveat is that MAX_SECTION_LENGTH is technically in tokens (which is what OpenAI limits by), but because
    # of how expensive it is to tokenize and recount, once we are at the edge of the max we resort to a simple string
    # slice. This will hopefully be less than or equal to the limit because tokens are at least one character long, AFAIK
    chosen_sections = []
    sections_length_so_far = 0

    sorted_book_section_titles.each do |title|
      break if sections_length_so_far >= MAX_SECTION_LENGTH

      df_row = book_pages_df[book_pages_df["title"] == title]
      sections_length_after_appending = sections_length_so_far + df_row["tokens"].to_a.first + SECTION_SEPARATOR_TOKEN_LENGTH

      content_to_append = SECTION_SEPARATOR + df_row["content"].to_a.first
      if sections_length_after_appending >= MAX_SECTION_LENGTH
        space_left = MAX_SECTION_LENGTH - sections_length_so_far
        # What we would really want here is to slice up to `space_left` tokens, but
        # we'll settle for characters for now
        content_to_append = content_to_append.slice(0, space_left)
      end

      chosen_sections << [content_to_append]
      sections_length_so_far = sections_length_after_appending
    end

    chosen_sections.join
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