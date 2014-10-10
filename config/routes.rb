Pykhub::Application.routes.draw do

  resources :providers


  #resource
  resource :settings
  #Settings
  get "/template", to: "settings#template", as: "template_settings"
  post "/template/save", to: "settings#update_template", as: "update_template"

  post '/login', to: "users#login", as: "login"  
  get '/login', to: "users#login", as: "login"
  get '/logout', to: "users#logout", as: "logout"  
  
  #articles
  get "/new", to: "cms_articles#new", as: "new_cms_articles"
  post "/create", to: "cms_articles#create", as: "create_cms_articles"
  get "/:file_id/edit", to: "cms_articles#edit", as: "edit_cms_article"
  put "/:file_id/update", to: "cms_articles#update", as: "update_cms_article"
  get "/:file_id/delete", to: "cms_articles#destroy", as: "delete_cms_article"
  post "/sort/tags", to: "cms_articles#sort", as: "sort_tags"
  get "/all-articles", to: "cms_articles#allArticles", as: "all_articles"
  get "/article/:file_id/:type", to: "cms_articles#publish_or_archieve", as: "pub_arch_article"
  get "page/:parent_article/:nested_article_name/:nested_article", to: "cms_articles#nested_article", as: "nested_article"
  
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
  get "/data/:file_id/json", to: "data_filzs#json_data", as: "data_filz_json"
  get "/data/euro/api", to: "data_filzs#euro_api", as: "euro_api_json"
    
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
  get "/generate/chart/:file_id", to: "viz_vizs#generate_chart", as: "generate_viz_chart"
  
  get "/:file_id", to: "cms_articles#show", as: "cms_article"

  
  #Embed
  get "/embed/:file_id", to: "viz_vizs#embed", as: "embed_viz"
  
  #root
  root :to => 'cms_articles#index'

end