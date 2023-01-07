class JokesController < ApplicationController
    def index
      Joke.create(body: "Knock! Knock! Whos there")  
      joke = Joke.order('RANDOM()').first
      render html: joke.body
    end
  end