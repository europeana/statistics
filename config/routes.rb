Pykhub::Application.routes.draw do
  
  #oauth2callback
  match '/auth/google_oauth2/callback' => 'core_oauths#create'
  match '/auth/google_oauth2/revalidate' => 'core_oauths#revalidate'

  #get "raw/index"
  #post "raw/upload"
  
  devise_for :users, :controllers => {:sessions => "sessions", :registrations => "registrations", :confirmations => "confirmations"}
  
  #users
  get "/settings", to: "users#edit", as: "edit_user"
  put "/:user_id/update", to: "users#update", as: "update_user"
  get "/integrations", to: "users#integrations", as: "integrations_user"

  #accounts
  get "new", to: "accounts#new", as: "new_accounts"
  post "create", to: "accounts#create", as: "accounts"
  put "/:user_id/:account_id/update", to: "accounts#update", as: "update_account"
  get "/:user_id/:account_id/settings", to: "accounts#edit", as: "edit_account"
  get "/:user_id/:account_id/delete", to: "accounts#destroy", as: "delete_account"  
  
  #collaboration
  post "/:user_id/:account_id/collaboration", to: "permissions#create", as: "user_account_permissions"
  get "/:user_id/:account_id/collaboration", to: "permissions#index", as: "user_account_permissions"
  get "/:user_id/:account_id/collaboration/:id/delete", to: "permissions#destroy", as: "user_account_permissions_delete"
  
  #transfer account
  post '/:user_id/:account_id/transfer', to: "accounts#transfer", as: "transfer_user_account"

  #specfic files
  get "/:user_id/:account_id/readme.md", to: "core_files#readme", as: "readme_user_account_core_file"
  get "/:user_id/:account_id/license.md", to: "core_files#license", as: "license_user_account_core_file"
  
  #files
  get "/:user_id/:account_id/:folder_id", to: "core_files#index", as: "user_account_core_files"
  get "/:user_id/:account_id/:folder_id/new", to: "core_files#new", as: "new_user_account_core_files"
  get "/:user_id/:account_id/:folder_id/apis", to: "core_files#apis", as: "apis_user_account_core_files"
  get "/:user_id/:account_id/:folder_id/:file_id/edit", to: "core_files#edit", as: "edit_user_account_core_file"
  post "/:user_id/:account_id/:folder_id/create", to: "core_files#create", as: "create_user_account_core_files"
  put "/:user_id/:account_id/:folder_id/:file_id/update", to: "core_files#update", as: "update_user_account_core_file"
  get "/:user_id/:account_id/:folder_id/:file_id/delete", to: "core_files#destroy", as: "delete_user_account_core_file"
  get "/:user_id/:account_id/:folder_id/:file_id/raw", to: "core_files#raw", as: "raw_user_account_core_file"
  get "/:user_id/:account_id/:folder_id/:file_id", to: "core_files#show", as: "user_account_core_file"

  #most specific routes come last
  get "/:user_id/:account_id", to: "accounts#show", as: "user_account"
  get "/:user_id", to: "users#show", as: "user"
  
  #root
  root :to => 'static_pages#index'
  
end