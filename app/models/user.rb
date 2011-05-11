class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :timeoutable and :oauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :admin, :show_cytoscape, :show_scoreboard

  has_many :curated_annotations, :class_name => "Annotation", :foreign_key => :curated_by_id
  has_many :created_annotations, :class_name => "Annotation", :foreign_key => :created_by_id

end
