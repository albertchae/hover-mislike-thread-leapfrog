## Must-do coverage

- Script to format PDF manuscript as local data file with embeddings
  - `lib/tasks/process_book.rake`, run with `bin/rake process_book -- --pdf book.pdf`

- Text box to receive question
  - `app/javascript/application.jsx`

- Backend fetches most relevant embeddings using local data file
  - `app/services/book_similarity.rb` takes in a embeddings from a local file and sorts by similarity (dot product/cosine)

- Backend caches answers, otherwise hits OpenAI for answer
  - `app/services/answer_generator.rb` looks up existing answers in DB by exact question text, otherwise asks OpenAI for a completion

- Front-end that displays answer
  - Also in `app/services/answer_generator.rb`


## Python to Ruby equivalents

| Library purpose | Python      | Ruby        |
| --------------- | ----------- | ----------- |
| PDF parsing | pypdf2 | pdf-reader |
| Dataframes | pandas | rover-df |
| Dot product | numpy | matrix |
| Tokenizing | transformers | tokenizers |
| OpenAI API | openai | ruby-openai |


## Overall approach and architecture decisions

My main goal was to get something working in the recommended time frame, so I tried to stick to technologies and paths I was already familiar. I also erred on the side of replicating the python codebase behavior when I didn't understand why a certain decision due to my unfamiliarity with the OpenAI API and applying the principle of [Chesterton's Fence](https://en.wiktionary.org/wiki/Chesterton%27s_fence).

- I chose to use a modern Rails 7 way of building a React frontend using esbuild. Although I had never done this before, it seemed simple enough from a brand new app and felt like something worth learning.

- It looked like dataframes were used in the python library purely for CSV parsing along with some light filtering. Although dataframes are not a common pattern in Ruby, I knew there were a few experimental libraries that were trying to provide a similar API, so I took this as an opportunity to learn what they were like and found it worked well for this project

- I believe in weighing cost vs benefits when writing automated tests, so I chose to write tests that served me the most during development. These were situations where I could use local data as much as possible. Anywhere I'd be forced to mock or stub an external interface was not that useful to me because I didn't have a strong understanding of the OpenAI API, so mocks would probably hurt me more than help because they would likely have diverged from the real API. If this was a production project with more members, I believe the value of such tests would be higher to prevent regressions or customer issues, so I would be more likely to consider testing those paths then.

- Because the entire app is a single screen, I went with the most barebones React frontend I could, which included a global CSS file (copied directly from the original project) and regular Javascript instead of Typescript.

- I chose to cache question/answers in the same way as the original project, which was using the exact question string as a search key. However, I did not choose to allow accessing individual question/answer by route e.g. https://askmybook.com/question/14 because I didn't want to deal with the frontend routing complexity for now. I also didn't store the context like the python app since it wasn't critical to the required functionality.

- I didn't do anything with voice/Resemble because it wasn't part of the requirements.

- I also didn't do any error handling from the OpenAI completions API because I'm expecting limited traffic. I would add this (and probably pay for OpenAI) if I expected this to be more widely used.

- I committed the pages/embeddings CSVs to the repo directly because that was the easiest way to load them and the content I used was open license. For books in general, I'd try to host the CSV files in a secure location accessible by the app or use a database for them instead.


## Lessons learned

- I should have invested in setting up some kind of test harness to compare the book embeddings generated vs the "reference" embeddings generated by the python codebase. Even though the numbers won't be the exact same unless the PDF contents were dumped out exactly the same, we could use the same technique of taking vector dot products and requiring some threshold similarity for the tests to pass. This could have saved me time wondering why some Unicode characters were giving me problems (see commit 4aff85643accda9a113871f1083a9a8df4b691da).

- On a similar note, `pdf-reader` didn't seem to that great at reading PDF contents. I did briefly try to use another library called `poppler` but had trouble getting it installed. Maybe I should have invested some time in Dockerizing the project to make installing stuff like `poppler` easier. This would probably also be better for an interview homework submission.


## Future ideas

- I would have liked to try to generate the prompt context from the source pdf. Currently it is hardcoded (and copied from python codebase) in `app/services/prompt_templater.rb` and based on The Minimalist Entrepreneur. However, it does still seem to do a good job of priming OpenAI completions to respect the Q/A format.

- I did like browsing previously answered questions by hitting `question/:id`, so I would figure out the React routing required to make that possible.

- It would be interesting to try breaking up the book by some other granularity than pages. An individual page could be pretty long in a PDF which would could come up against OpenAI token limits and also suffer from arbitrary page breaks in between relevant sections. I think trying with paragraphs or sentences could be intersting, although certainly more complex than just going by page.