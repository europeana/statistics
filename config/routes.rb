Pykhub::Application.routes.draw do
  
  post '/login', to: "users#login", as: "login"  
  get '/login', to: "users#login", as: "login"
  get '/logout', to: "users#logout", as: "logout"  
  get '/demo', to: "users#demo", as: "demo"  
  
  #articles
  get "/new", to: "cms_articles#new", as: "new_cms_articles"
  post "/create", to: "cms_articles#create", as: "create_cms_articles"
  get "/:file_id/edit", to: "cms_articles#edit", as: "edit_cms_article"
  put "/:file_id/update", to: "cms_articles#update", as: "update_cms_article"
  get "/:file_id/delete", to: "cms_articles#destroy", as: "delete_cms_article"
  
  #files
  get "/data", to: "data_filzs#index", as: "data_filzs"
  get "/data/new", to: "data_filzs#new", as: "new_data_filzs"
  get "/articles/:file_id/csv", to: "data_filzs#csv", as: "csv_data_filz"
  get "/data/:file_id/edit", to: "data_filzs#edit", as: "edit_data_filz"
  post "/data/create", to: "data_filzs#create", as: "create_data_filzs"
  put "/data/:file_id/update", to: "data_filzs#update", as: "update_data_filz"
  get "/data/:file_id/delete", to: "data_filzs#destroy", as: "delete_data_filz"
  get "/data/:file_id/raw", to: "data_filzs#raw", as: "raw_data_filz"
  get "/data/:file_id", to: "data_filzs#show", as: "data_filz"
  
  #tags
  get "/tags", to: "core_tags#index", as: "core_tags"
  post "/tags/create", to: "core_tags#create", as: "create_core_tags"
  put "/tags/:tag_id/edit", to: "core_tags#edit", as: "edit_core_tag"
  put "/tags/:tag_id/update", to: "core_tags#update", as: "update_core_tag"
  get "/tags/:tag_id/delete", to: "core_tags#destroy", as: "delete_core_tag"
  
  #images
  post "/images/create", to: "cms_images#create", as: "create_cms_images"
  
  #viz
  get "/visualizations", to: "viz_vizs#index", as: "viz_vizs"
  get "/visualizations/new", to: "viz_vizs#new", as: "new_viz_vizs"
  get "/visualizations/:file_id/map", to: "viz_vizs#map", as: "map_viz_viz"  
  get "/visualizations/:file_id/edit", to: "viz_vizs#edit", as: "edit_viz_viz"
  post "/visualizations/create", to: "viz_vizs#create", as: "create_viz_vizs"
  put "/visualizations/:file_id/update", to: "viz_vizs#update", as: "update_viz_viz"
  get "/visualizations/:file_id/put_map", to: "viz_vizs#put_map", as: "put_map_viz_viz"
  get "/visualizations/:file_id/delete", to: "viz_vizs#destroy", as: "delete_viz_viz"
  get "/visualizations/:file_id", to: "viz_vizs#show", as: "viz_viz"
  
  get "/:file_id", to: "cms_articles#show", as: "cms_article"
  
  #root
  root :to => 'cms_articles#index'
  
end