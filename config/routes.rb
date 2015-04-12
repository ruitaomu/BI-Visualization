Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 's3_signatures' => 's3_signatures#create', as: :s3_signatures
end
