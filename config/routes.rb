ActionController::Routing::Routes.draw do |map|

  map.resources :platforms, :datasets, :samples, :series_items, :ontologies, :ontology_terms, :results, :detections, :probesets

  map.resources :jobs,
                :collection => {
                                :process => :post,
                                :statistics => :get
                              }

  map.resources :annotations,
            :collection => { :cloud => :get,
                             :audit => :get,
                             :valid => :post,
                             :invalid => :post
                           },
            :member => { :curate => :post }

  map.resource :account, :except => :destroy
  map.resources :password_resets, :only => [:new, :create, :edit, :update]
  map.resources :users
  map.resource :user_session, :only => [:new, :create, :destroy]
  map.signin 'signin', :controller => "user_sessions", :action => "new"
  map.signout 'signout', :controller => "user_sessions", :action => "destroy"
  map.activate '/activate/:activation_code', :controller => 'activations', :action => 'new'
  map.finish_activate '/finish_activate/:id', :controller => 'activations', :action => 'create'
  map.help '/help', :controller => 'pages', :action => 'help'

  map.signup 'signup', :controller => "accounts", :action => "new"
  map.root :controller => "pages", :action => "home"
  map.pages 'pages/:action', :controller => "pages"
end
