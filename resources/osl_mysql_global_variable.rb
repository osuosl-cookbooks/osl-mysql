resource_name :osl_mysql_global_variable
provides :osl_mysql_global_variable
default_action :set
unified_mode true

property :variable, String, name_property: true, regex: /\A[a-z0-9_]+\z/
# Digits only: @@GLOBAL reports numbers plainly, so the comparison is exact (no 128M vs 134217728)
property :value, [String, Integer], required: true, coerce: proc(&:to_s), regex: /\A\d+\z/
property :defaults_file, String, default: '/root/.my.cnf'

action :set do
  current = osl_mysql_global_variable_value(new_resource.variable, new_resource.defaults_file)

  # SET GLOBAL, not SET PERSIST: mysqld-auto.cnf would override my.cnf after every restart
  execute "SET GLOBAL #{new_resource.variable} = #{new_resource.value}" do
    command ['mysql', "--defaults-file=#{new_resource.defaults_file}", '-e',
             "SET GLOBAL #{new_resource.variable} = #{new_resource.value}"]
    only_if { !current.nil? && current != new_resource.value }
  end
end
