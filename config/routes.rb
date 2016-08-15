Rails.application.routes.draw do
  get 'base/verify'
  get 'base/index'
  root 'base#index'
end
