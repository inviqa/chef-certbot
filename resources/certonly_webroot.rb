actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :webroot_path, :kind_of => String, :required => true
attribute :email, :kind_of => String, :required => true
attribute :domains, :kind_of => Array, :required => true
attribute :expand, :kind_of => [ TrueClass, FalseClass ],
            :default => false
attribute :agree_tos, :kind_of => [ TrueClass, FalseClass ],
            :default => false
