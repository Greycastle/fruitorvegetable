Rails.application.routes.draw do
  get 'verify', to: 'base#verify'
  get 'about', to: 'base#about'
  get 'reset', to: 'base#reset'

  root 'base#index'
end
