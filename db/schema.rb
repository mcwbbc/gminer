# This file is auto-generated from the current state of the database. Instead of editing this file,
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 15) do

  create_table "annotation_closures", :force => true do |t|
    t.integer "annotation_id"
    t.integer "ontology_term_id"
  end

  add_index "annotation_closures", ["annotation_id"], :name => "index_annotation_closures_on_annotation_id"
  add_index "annotation_closures", ["ontology_term_id"], :name => "index_annotation_closures_on_ontology_term_id"

  create_table "annotations", :force => true do |t|
    t.integer "ontology_id"
    t.integer "ontology_term_id"
    t.string  "geo_accession",    :limit => 25
    t.string  "field",            :limit => 25
    t.string  "ncbo_id",          :limit => 100
    t.string  "description"
    t.integer "from"
    t.integer "to"
    t.boolean "verified",                        :default => false
    t.boolean "audited",                         :default => false
    t.integer "user_id",                         :default => 0
  end

  add_index "annotations", ["field"], :name => "index_annotations_on_field"
  add_index "annotations", ["geo_accession"], :name => "index_annotations_on_geo_accession"
  add_index "annotations", ["ncbo_id"], :name => "index_annotations_on_ncbo_id"
  add_index "annotations", ["ontology_id"], :name => "index_annotations_on_ontology_id"
  add_index "annotations", ["ontology_term_id"], :name => "index_annotations_on_ontology_term_id"
  add_index "annotations", ["user_id"], :name => "index_annotations_on_user_id"

  create_table "datasets", :force => true do |t|
    t.integer "platform_id"
    t.string  "geo_accession",    :limit => 25
    t.string  "reference_series", :limit => 25
    t.string  "pubmed_id",        :limit => 25
    t.string  "organism"
    t.text    "title"
    t.text    "description"
  end

  add_index "datasets", ["geo_accession"], :name => "index_datasets_on_geo_accession"
  add_index "datasets", ["platform_id"], :name => "index_datasets_on_platform_id"

  create_table "detections", :force => true do |t|
    t.integer "sample_id"
    t.string  "id_ref",      :limit => 100
    t.string  "abs_call",    :limit => 2
    t.integer "probeset_id"
  end

  add_index "detections", ["abs_call"], :name => "index_detections_on_abs_call"
  add_index "detections", ["id_ref"], :name => "index_detections_on_id_ref"
  add_index "detections", ["probeset_id"], :name => "index_detections_on_probeset_id"
  add_index "detections", ["sample_id"], :name => "index_detections_on_sample_id"

  create_table "jobs", :force => true do |t|
    t.integer  "ontology_id"
    t.string   "worker_key",    :limit => 50
    t.string   "geo_accession", :limit => 25
    t.string   "field",         :limit => 50
    t.datetime "created_at"
    t.float    "started_at"
    t.float    "working_at"
    t.float    "finished_at"
  end

  add_index "jobs", ["geo_accession"], :name => "index_jobs_on_geo_accession"
  add_index "jobs", ["ontology_id"], :name => "index_jobs_on_ontology_id"
  add_index "jobs", ["worker_key"], :name => "index_jobs_on_worker_key"

  create_table "ontologies", :force => true do |t|
    t.string   "current_ncbo_id", :limit => 100
    t.string   "ncbo_id",         :limit => 100
    t.string   "name"
    t.string   "version",         :limit => 25
    t.text     "stopwords"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "ontologies", ["current_ncbo_id"], :name => "index_ontologies_on_current_ncbo_id"
  add_index "ontologies", ["ncbo_id"], :name => "index_ontologies_on_ncbo_id"

  create_table "ontology_terms", :force => true do |t|
    t.integer "ontology_id"
    t.string  "term_id",           :limit => 100
    t.string  "ncbo_id",           :limit => 100
    t.string  "name"
    t.integer "annotations_count",                :default => 0
  end

  add_index "ontology_terms", ["ncbo_id"], :name => "index_ontology_terms_on_ncbo_id"
  add_index "ontology_terms", ["ontology_id"], :name => "index_ontology_terms_on_ontology_id"
  add_index "ontology_terms", ["term_id"], :name => "index_ontology_terms_on_term_id"

  create_table "platforms", :force => true do |t|
    t.string "geo_accession", :limit => 25
    t.string "title"
    t.string "organism"
  end

  add_index "platforms", ["geo_accession"], :name => "index_platforms_on_geo_accession"

  create_table "probesets", :force => true do |t|
    t.string "name", :limit => 100
  end

  add_index "probesets", ["name"], :name => "index_probesets_on_name", :unique => true

  create_table "results", :force => true do |t|
    t.integer "sample_id"
    t.integer "probeset_id"
    t.integer "ontology_term_id"
    t.string  "pubmed_id",        :limit => 25
  end

  add_index "results", ["ontology_term_id"], :name => "index_results_on_ontology_term_id"
  add_index "results", ["probeset_id"], :name => "index_results_on_probeset_id"
  add_index "results", ["sample_id"], :name => "index_results_on_sample_id"

  create_table "samples", :force => true do |t|
    t.integer "series_item_id"
    t.integer "platform_id"
    t.string  "geo_accession",      :limit => 25
    t.string  "sample_type"
    t.string  "source_name"
    t.string  "organism"
    t.string  "label"
    t.string  "molecule"
    t.text    "title"
    t.text    "characteristics"
    t.text    "treatment_protocol"
    t.text    "extract_protocol"
    t.text    "label_protocol"
    t.text    "scan_protocol"
    t.text    "hyp_protocol"
    t.text    "description"
    t.text    "data_processing"
  end

  add_index "samples", ["geo_accession"], :name => "index_samples_on_geo_accession"
  add_index "samples", ["platform_id"], :name => "index_samples_on_platform_id"
  add_index "samples", ["series_item_id"], :name => "index_samples_on_series_item_id"

  create_table "series_items", :force => true do |t|
    t.integer "platform_id"
    t.string  "geo_accession",  :limit => 25
    t.string  "pubmed_id",      :limit => 25
    t.string  "title"
    t.text    "summary"
    t.text    "overall_design"
  end

  add_index "series_items", ["geo_accession"], :name => "index_series_items_on_geo_accession"
  add_index "series_items", ["platform_id"], :name => "index_series_items_on_platform_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email",             :default => "", :null => false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                 :null => false
    t.integer  "login_count",       :default => 0,  :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "roles"
    t.string   "perishable_token",  :default => "", :null => false
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

  create_table "workers", :force => true do |t|
    t.string  "worker_key", :limit => 50
    t.boolean "ready",                    :default => false
    t.boolean "working",                  :default => false
  end

  add_index "workers", ["ready"], :name => "index_workers_on_ready"
  add_index "workers", ["worker_key"], :name => "index_workers_on_worker_key"
  add_index "workers", ["working"], :name => "index_workers_on_working"

  add_foreign_key "annotation_closures", "annotations", :column => "annotation_id", :name => "annotation_closures_annotation_id_fk", :dependent => :delete
  add_foreign_key "annotation_closures", "ontology_terms", :column => "ontology_term_id", :name => "annotation_closures_ontology_term_id_fk", :dependent => :delete

  add_foreign_key "annotations", "ontologies", :column => "ontology_id", :name => "annotations_ontology_id_fk", :dependent => :delete
  add_foreign_key "annotations", "ontology_terms", :column => "ontology_term_id", :name => "annotations_ontology_term_id_fk", :dependent => :delete

  add_foreign_key "datasets", "platforms", :column => "platform_id", :name => "datasets_platform_id_fk", :dependent => :delete

  add_foreign_key "detections", "samples", :column => "sample_id", :name => "detections_sample_id_fk", :dependent => :delete

  add_foreign_key "ontology_terms", "ontologies", :column => "ontology_id", :name => "ontology_terms_ontology_id_fk", :dependent => :delete

  add_foreign_key "results", "ontology_terms", :column => "ontology_term_id", :name => "results_ontology_term_id_fk", :dependent => :delete
  add_foreign_key "results", "samples", :column => "sample_id", :name => "results_sample_id_fk", :dependent => :delete

  add_foreign_key "samples", "platforms", :column => "platform_id", :name => "samples_platform_id_fk", :dependent => :delete
  add_foreign_key "samples", "series_items", :column => "series_item_id", :name => "samples_series_item_id_fk", :dependent => :delete

  add_foreign_key "series_items", "platforms", :column => "platform_id", :name => "series_items_platform_id_fk", :dependent => :delete

end
