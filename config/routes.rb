Gminer::Application.routes.draw do

  devise_for :users

  resources :users, :only => [:show]

  resources :datasets, :samples, :series_items, :ontologies, :ontology_terms, :results, :detections, :resource_index_annotations

  resources :platforms do
    collection do
      post :skip_annotations
    end
  end

  resources :cytoscapes do
    collection do
      post :resource_count
      post :resource_count_hash
    end

    member do
      get :resource_term_ids
      get :item_json
    end
  end

  resources :probesets do
    member do
      get :compare
    end
  end

  resources :tags do
    collection do
      post :create_for
      post :delete_for
    end

    member do
      post :delete_for
    end
  end

  resources :reports do
    collection do
      get :progress
      get :job_statistics
      get :annotation
      get :manual_annotation_terms
      get :comparison
    end
  end

  resources :jobs do
    collection do
      get :graph_status
      get :dashboard
      post :process
      post :update_job_form
    end
  end

  resources :annotations do
    collection do
      get :top_curators
      get :cloud
      get :audit
      get :item_audit
      post :mass_curate
    end

    member do
      post :predicate
      post :curate
      get :geo_item
    end
  end

  match '/help', :to => 'pages#help', :as => 'help'
  match '/rdf', :to => 'pages#rdf', :as => 'rdf'
  root :to => 'pages#home'

end
