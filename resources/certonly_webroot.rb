actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true, :required => true

attribute :agree_tos, :kind_of => [ TrueClass, FalseClass ],
            :default => false
attribute :cert_name, :kind_of => String, :default => nil
attribute :domains, :kind_of => Array, :required => true
attribute :email, :kind_of => String, :required => true
attribute :expand, :kind_of => [ TrueClass, FalseClass ],
            :default => false
attribute :rsa_key_size, :kind_of => Integer, default: 2048
attribute :staging, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :webroot_path, :kind_of => String, :required => true

