## App

Currently hosted at https://hover-mislike-thread-leapfrog.herokuapp.com/

## Setup

1. Create and fill in `.env` using `.env.example` as an example.

2. Install required Ruby as specified in `.ruby-version`. I used https://github.com/rbenv/rbenv but use whatever you prefer

3. Install required postgres as specified in `.tool-versions`. I used https://asdf-vm.com/.

4. Install gems

```
bundle install
```

5. Create database

```
bin/rails db:prepare db:migrate
```

6. Turn your PDF into embeddings for GPT-3:

```
bin/rake process_book -- --pdf book.pdf
```
