# frozen_string_literal: true

require 'rails_helper'

require 'matrix'

describe BookSimilarity do
  let(:book_embeddings_df) {
    Rover::DataFrame.new([
                           {title: "Page 1", "0": 0, "1": 1},
                           {title: "Page 2", "0": 1, "1": 0},
                           {title: "Page 3", "0": -1, "1": 0}
                         ])
  }

  describe '#book_sections_sorted_by_relevance' do
    context 'when given a dataframe of 3 vectors' do
      it 'sorts them by similarity to target vector' do
        most_similar_sections = BookSimilarity.new(book_embeddings_df).
          book_sections_sorted_by_relevance(Vector[1, 0])

        expect(most_similar_sections).
          to eq(
               [
                 ["Page 2", Vector[1, 0]],
                 ["Page 1", Vector[0, 1]],
                 ["Page 3", Vector[-1, 0]]
               ]
             )

      end
    end
  end

  describe '#book_titles_sorted_by_relevance' do
    context 'when given a dataframe of 3 vectors' do
      it 'returns titles of sections sorted by similarity to target vector' do
        most_similar_titles = BookSimilarity.new(book_embeddings_df).
          book_titles_sorted_by_relevance(Vector[1, 0])

        expect(most_similar_titles).
          to eq(
               [
                 "Page 2",
                 "Page 1",
                 "Page 3"
               ]
             )

      end
    end
  end
end
