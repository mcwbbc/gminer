# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 19) do

  create_table "annotation_closures", :force => true do |t|
    t.integer  "annotation_id"
    t.integer  "ontology_term_id"
    t.datetime "created_at"
    t.string   "identifier"
    t.string   "geo_accession",    :limit => 25
    t.string   "field_name",       :limit => 50
    t.string   "term_id"
    t.string   "closure_term_id"
  end

  add_index "annotation_closures", ["annotation_id"], :name => "index_annotation_closures_on_annotation_id"
  add_index "annotation_closures", ["ontology_term_id"], :name => "index_annotation_closures_on_ontology_term_id"

  create_table "annotations", :force => true do |t|
    t.integer  "ontology_id"
    t.integer  "ontology_term_id"
    t.string   "identifier"
    t.string   "geo_accession",    :limit => 25
    t.string   "field_name",       :limit => 25
    t.string   "term_id"
    t.string   "ncbo_id",          :limit => 100
    t.string   "predicate"
    t.string   "description"
    t.integer  "from"
    t.integer  "to"
    t.boolean  "verified",                        :default => false
    t.string   "status",           :limit => 20,  :default => "unaudited"
    t.integer  "created_by_id",                   :default => 0
    t.integer  "curated_by_id",                   :default => 0
    t.boolean  "mapping"
    t.boolean  "synonym"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["created_by_id"], :name => "index_annotations_on_created_by_id"
  add_index "annotations", ["curated_by_id"], :name => "index_annotations_on_curated_by_id"
  add_index "annotations", ["field_name"], :name => "index_annotations_on_field"
  add_index "annotations", ["geo_accession"], :name => "index_annotations_on_geo_accession"
  add_index "annotations", ["identifier"], :name => "index_annotations_on_identifier", :unique => true
  add_index "annotations", ["ncbo_id"], :name => "index_annotations_on_ncbo_id"
  add_index "annotations", ["ontology_id"], :name => "index_annotations_on_ontology_id"
  add_index "annotations", ["ontology_term_id"], :name => "index_annotations_on_ontology_term_id"
  add_index "annotations", ["status"], :name => "index_annotations_on_status"
  add_index "annotations", ["term_id"], :name => "index_annotations_on_term_id"

  create_table "comparisons", :force => true do |t|
    t.integer  "ontology_id"
    t.integer  "ontology_term_id"
    t.string   "identifier"
    t.string   "geo_accession",    :limit => 25
    t.string   "field_name",       :limit => 25
    t.string   "term_id"
    t.string   "ncbo_id",          :limit => 100
    t.string   "description"
    t.integer  "from"
    t.integer  "to"
    t.boolean  "verified",                        :default => false
    t.string   "status",           :limit => 20,  :default => "unaudited"
    t.integer  "created_by_id"
    t.integer  "curated_by_id"
    t.boolean  "mapping"
    t.boolean  "synonym"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "archived_at"
  end

  add_index "comparisons", ["archived_at"], :name => "index_comparisons_on_archived_at"
  add_index "comparisons", ["field_name"], :name => "index_comparisons_on_field"
  add_index "comparisons", ["geo_accession"], :name => "index_comparisons_on_geo_accession"
  add_index "comparisons", ["identifier"], :name => "index_comparisons_on_identifier", :unique => true
  add_index "comparisons", ["ncbo_id"], :name => "index_comparisons_on_ncbo_id"
  add_index "comparisons", ["ontology_id"], :name => "index_comparisons_on_ontology_id"
  add_index "comparisons", ["ontology_term_id"], :name => "index_comparisons_on_ontology_term_id"
  add_index "comparisons", ["status"], :name => "index_comparisons_on_status"

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

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "detections", :force => true do |t|
    t.integer "sample_id"
    t.integer "probeset_id"
    t.string  "abs_call",    :limit => 2
  end

  add_index "detections", ["abs_call"], :name => "index_detections_on_abs_call"
  add_index "detections", ["probeset_id"], :name => "index_detections_on_probeset_id"
  add_index "detections", ["sample_id"], :name => "index_detections_on_sample_id"

  create_table "jobs", :force => true do |t|
    t.integer  "ontology_id"
    t.string   "worker_key",    :limit => 50
    t.string   "geo_accession", :limit => 25
    t.string   "field_name",    :limit => 50
    t.datetime "created_at"
    t.float    "started_at"
    t.float    "working_at"
    t.float    "finished_at"
  end

  add_index "jobs", ["geo_accession"], :name => "index_jobs_on_geo_accession"
  add_index "jobs", ["ontology_id"], :name => "index_jobs_on_ontology_id"
  add_index "jobs", ["worker_key"], :name => "index_jobs_on_worker_key"

  create_table "ontologies", :force => true do |t|
    t.integer  "ncbo_id"
    t.integer  "current_ncbo_id"
    t.string   "name"
    t.string   "version",           :limit => 25
    t.text     "stopwords"
    t.string   "expand_ontologies"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ontologies", ["current_ncbo_id"], :name => "index_ontologies_on_current_ncbo_id"
  add_index "ontologies", ["ncbo_id"], :name => "index_ontologies_on_ncbo_id"

  create_table "ontology_terms", :force => true do |t|
    t.integer  "ontology_id"
    t.string   "term_id",           :limit => 100
    t.string   "ncbo_id",           :limit => 100
    t.string   "name"
    t.integer  "annotations_count",                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string  "name",     :limit => 100
    t.integer "rgd_gene"
    t.string  "symbol"
  end

  add_index "probesets", ["name"], :name => "index_probesets_on_name"
  add_index "probesets", ["rgd_gene"], :name => "index_probesets_on_rgd_gene"

  create_table "resource_index_annotations", :force => true do |t|
    t.string  "identifier"
    t.string  "geo_accession", :limit => 25
    t.string  "field_name",    :limit => 25
    t.string  "ncbo_id",       :limit => 100
    t.string  "term_id"
    t.integer "from"
    t.integer "to"
  end

  add_index "resource_index_annotations", ["field_name"], :name => "index_resource_index_annotations_on_field_name"
  add_index "resource_index_annotations", ["geo_accession"], :name => "index_resource_index_annotations_on_geo_accession"
  add_index "resource_index_annotations", ["identifier"], :name => "index_resource_index_annotations_on_identifier"
  add_index "resource_index_annotations", ["ncbo_id"], :name => "index_resource_index_annotations_on_ncbo_id"
  add_index "resource_index_annotations", ["term_id"], :name => "index_resource_index_annotations_on_term_id"

  create_table "results", :force => true do |t|
    t.integer "sample_id"
    t.integer "ontology_term_id"
    t.integer "probeset_id"
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

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
    t.string "description"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",    :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",    :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin",                               :default => false
    t.boolean  "show_cytoscape",                      :default => false
    t.boolean  "show_scoreboard",                     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "workers", :force => true do |t|
    t.string   "worker_key", :limit => 50
    t.boolean  "ready",                    :default => false
    t.boolean  "working",                  :default => false
    t.datetime "updated_at"
  end

  add_index "workers", ["ready"], :name => "index_workers_on_ready"
  add_index "workers", ["worker_key"], :name => "index_workers_on_worker_key"
  add_index "workers", ["working"], :name => "index_workers_on_working"

end
