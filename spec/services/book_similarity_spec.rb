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

  describe '#relevant_sections' do
    context 'when given a question and book embedding and pages dataframe' do
      let(:book_pages_df) {
        Rover::DataFrame.new([
                               {title: "Page 1", "content": "Page 1 content"},
                               {title: "Page 2", "content": "Page 2 content"},
                               {title: "Page 3", "content": "Page 3 content"}
                             ])
      }

      it 'returns the contents of the pages from most similar to least' do
        relevant_sections = BookSimilarity.new(book_embeddings_df).
          relevant_sections(Vector[1, 0], book_pages_df)

        expected_context = <<~RELEVANT_SECTIONS.chomp # remove trailing newline

        * Page 2 content
        * Page 1 content
        * Page 3 content
        RELEVANT_SECTIONS

        expect(relevant_sections).to eq(expected_context)
      end
    end
  end
end
