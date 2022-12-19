# frozen_string_literal: true

Rails.application.routes.draw do
  get '/start', to: 'bot#start'
  get '/state', to: 'bot#state'
  get '/stop', to: 'bot#stop'
end
