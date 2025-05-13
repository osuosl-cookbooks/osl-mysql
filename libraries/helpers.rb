module OslMysql
  module Cookbook
    module Helpers
      def osl_mysql_conf
        node.override['percona']['backup']['configure'] = true
        node.override['percona']['conf']['mysqld']['auto_increment_increment'] = '3'
        node.override['percona']['conf']['mysqld']['innodb_default_row_format'] = 'DYNAMIC'
        node.override['percona']['conf']['mysqld']['innodb_file_per_table'] = 'ON'
        # utf8mb4 support
        node.override['percona']['conf']['mysqld']['innodb_large_prefix'] = 'true' if node['percona']['version'].to_f < 8.0
        # Loosen restrictions on type of functions users can create
        node.override['percona']['conf']['mysqld']['log_bin_trust_function_creators'] = '1'
        node.override['percona']['conf']['mysqld']['net_write_timeout'] = '600'
        # Skip common errors with secondary syncing
        # 1062: HA_ERR_FOUND_DUPP_KEY
        # 1032: HA_ERR_KEY_NOT_FOUND
        node.override['percona']['conf']['mysqld']['slave-skip-errors'] = '1062,1032'
        node.override['percona']['conf']['mysqld']['ssl_ca'] = 'ca.pem'
        node.override['percona']['conf']['mysqld']['ssl_cert'] = 'server-cert.pem'
        node.override['percona']['conf']['mysqld']['ssl_key'] = 'server-key.pem'
        # enable user monitoring by default
        node.override['percona']['conf']['mysqld']['userstat'] = true
        node.override['percona']['server']['bind_address'] = '0.0.0.0'
        node.override['percona']['server']['binlog_format'] = 'ROW'
        node.override['percona']['server']['connect_timeout'] = '28880'
        node.override['percona']['server']['character_set'] = osl_char_settings[:character_set_server]
        node.override['percona']['server']['collation'] = osl_char_settings[:collation_server]
        node.override['percona']['server']['debian_username'] = 'root'
        node.override['percona']['server']['expire_logs_days'] = '14'
        node.override['percona']['server']['innodb_buffer_pool_instances'] = innodb_buffer_pool_instances
        node.override['percona']['server']['innodb_buffer_pool_size'] = innodb_buffer_pool_size
        node.override['percona']['server']['innodb_file_format'] = 'barracuda'
        node.override['percona']['server']['innodb_file_per_table'] = true
        node.override['percona']['server']['innodb_flush_log_at_trx_commit'] = 2
        node.override['percona']['server']['innodb_flush_method'] = 'O_DIRECT'
        node.override['percona']['server']['innodb_log_buffer_size'] = '64M'
        node.override['percona']['server']['innodb_log_files_in_group'] = 2
        if osl_percona_version == '5.7'
          node.override['percona']['server']['innodb_log_file_size'] = innodb_redo_log_settings[:log_file_size]
          node.override['percona']['server']['innodb_log_files_in_group'] =
            innodb_redo_log_settings[:log_files_in_group]
          node.override['percona']['server']['log_warnings'] = true
        elsif osl_percona_version == '8.0'
          node.override['percona']['conf']['mysqld']['innodb_redo_log_capacity'] =
            innodb_redo_log_settings[:redo_log_capacity]
        end
        node.override['percona']['conf']['mysqld']['innodb_read_io_threads'] = innodb_io_threads
        node.override['percona']['conf']['mysqld']['innodb_write_io_threads'] = innodb_io_threads
        node.override['percona']['conf']['mysqld']['innodb_purge_threads'] = innodb_purge_threads
        node.override['percona']['server']['join_buffer_size'] = '8M'
        node.override['percona']['server']['key_buffer_size'] = '32M'
        node.override['percona']['server']['log_bin_basename'] = '/var/lib/mysql/mysql-bin'
        node.override['percona']['server']['long_query_time'] = '3'
        node.override['percona']['server']['max_allowed_packet'] = '128M'
        node.override['percona']['server']['max_connect_errors'] = '1000000'
        node.override['percona']['server']['max_connections'] = 10000
        node.override['percona']['server']['max_heap_table_size'] = '128M'
        node.override['percona']['server']['myisam_recover_options'] = 'FORCE,BACKUP'
        node.override['percona']['server']['net_read_timeout'] = '300'
        node.override['percona']['server']['open_files_limit'] = '65536'
        node.override['percona']['server']['performance_schema'] = true
        node.override['percona']['server']['pidfile'] = '/var/lib/mysql/mysql.pid'
        node.override['percona']['server']['query_cache_type'] = '0'
        node.override['percona']['server']['relay_log'] = '' # use the default value
        node.override['percona']['server']['slave_net_timeout'] = '60'
        node.override['percona']['server']['slow_query_log_file'] = '/var/lib/mysql/mysql-slow.log'
        node.override['percona']['server']['sort_buffer_size'] = '4M'
        node.override['percona']['server']['sync_binlog'] = '1'
        node.override['percona']['server']['sql_modes'] = osl_sql_modes
        node.override['percona']['server']['sysdate_is_now'] = '1'
        node.override['percona']['server']['table_cache'] = '10240'
        node.override['percona']['server']['table_definition_cache'] = '4096'
        node.override['percona']['server']['thread_cache_size'] = 8 + (10000 / 100)
        node.override['percona']['server']['tmp_table_size'] = '128M'
        node.override['percona']['server']['transaction_isolation'] = 'READ-COMMITTED'
        node.override['percona']['server']['wait_timeout'] = '900'
        node.override['percona']['skip_passwords'] = false
      end

      def osl_min_free_kbytes
        # Set to 1% of total memory
        # https://discuss.aerospike.com/t/how-to-tune-the-linux-kernel-for-memory-performance/4195
        min_free_kbytes = Integer(osl_total_ram_mb * 1024 * 0.01)
        # Don't set above 2GB
        if (min_free_kbytes / 1048576) >= 2
          '2097152'
        else
          min_free_kbytes
        end
      end

      private

      def osl_percona_version
        node['percona']['version'].to_s
      end

      def osl_total_ram_mb
        # Calculate the InnoDB buffer pool size and instances
        # Ohai reports memory in kB
        (node['memory']['total'].split('kB')[0].to_i / 1024) # in MB
      end

      def osl_total_cpu_cores
        node['cpu']['cores'].to_i
      end

      # Calculate innodb_buffer_pool_size
      # Assumes a dedicated database server. Adjust percentage if not.
      def innodb_buffer_pool_size
        ram_mb = osl_total_ram_mb

        # Basic rules for buffer pool size
        # For very small instances (e.g., < 1GB RAM), be more conservative.
        # For very large instances (> 128GB RAM), you might not need 80% if OS/other caches are effective.
        buffer_pool_mb =
          if ram_mb < 1024 # Less than 1GB RAM
            (ram_mb * 0.25).ceil # e.g., 25%
          elsif ram_mb < 4096 # Less than 4GB RAM
            (ram_mb * 0.50).ceil # 50%
          else # More than 4GB RAM
            (ram_mb * 0.70).ceil
          end

        # Ensure a minimum reasonable size, e.g., 128M
        buffer_pool_mb = [buffer_pool_mb, 128].max

        # InnoDB buffer pool size must be a multiple of innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances
        # innodb_buffer_pool_chunk_size defaults to 128MB in 5.7.11+ (if pool > 1GB) or can be configured.
        # For simplicity here, we'll just return the calculated size.
        # For precise tuning, ensure it's a multiple of (chunk_size * instances).
        # For now, we just round up to the nearest M.
        "#{buffer_pool_mb}M"
      end

      # Calculate innodb_buffer_pool_instances
      def innodb_buffer_pool_instances
        cores = osl_total_cpu_cores
        buffer_pool_mb = innodb_buffer_pool_size.to_s.delete('M').to_i

        if buffer_pool_mb < 1024 # If buffer pool is less than 1GB
          1
        else
          # Rule: 1 instance per GB of buffer pool, up to number of cores.
          # Cap at a practical maximum like 16 or 32 if desired, though 5.7 handles more.
          # Percona often recommends matching cores for large buffer pools.
          instances_by_gb = (buffer_pool_mb / 1024.0).ceil
          [cores, instances_by_gb, 64].min # Cap at 64 (InnoDB internal max)
        end
      end

      # Calculate InnoDB Redo Log settings
      def innodb_redo_log_settings(percentage_of_pool = 0.25)
        buffer_pool_mb = innodb_buffer_pool_size.to_s.delete('M').to_i
        total_log_capacity_mb = (buffer_pool_mb * percentage_of_pool).ceil
        # Ensure a minimum sensible total log capacity, e.g., 256MB
        total_log_capacity_mb = [total_log_capacity_mb, 256].max

        # Round to sensible values (powers of 2 often, or common sizes)
        rounded_capacity_mb =
          if total_log_capacity_mb <= 256
            256
          elsif total_log_capacity_mb <= 512
            512
          elsif total_log_capacity_mb <= 1024
            1024
          elsif total_log_capacity_mb <= 2048
            2048
          elsif total_log_capacity_mb <= 4096
            4096
          else
            8192
          end

        if osl_percona_version == '5.7'
          # For 5.7, we need individual file size. Assume 2 files.
          log_files_in_group = 2 # node['percona']['innodb_log_files_in_group'] || 2
          single_log_file_mb = (rounded_capacity_mb / log_files_in_group.to_f).ceil
          # Ensure single_log_file_mb is also rounded nicely if desired, or convert to string with 'M'
          # Using the same rounding logic for individual file:
          single_log_file_val =
              if single_log_file_mb <= 128
                '128M'
              elsif single_log_file_mb <= 256
                '256M'
              elsif single_log_file_mb <= 512
                '512M'
              elsif single_log_file_mb <= 1024
                '1G'
              elsif single_log_file_mb <= 2048
                '2G'
              else
                '4G'
              end
          {
            log_file_size: single_log_file_val,
            log_files_in_group: log_files_in_group,
          }
        else # 8.0
          # Ensure capacity is at least 4MB * innodb_page_size / 512 (around 128MB for 16k pages)
          # Max total size is limited (around 512GB).
          # The rounding above should be fine.
          {
            redo_log_capacity: "#{rounded_capacity_mb}M",
          }
        end
      end

      # Calculate innodb_io_threads (read and write)
      def innodb_io_threads
        cores = osl_total_cpu_cores
        if cores <= 4
          4
        elsif cores <= 8
          8
        elsif cores <= 16
          16
        else
          [cores, 32].min
        end
      end

      # Calculate innodb_purge_threads
      def innodb_purge_threads
        cores = osl_total_cpu_cores
        major_version = osl_percona_version
        default_purge_threads = (major_version == '5.7' || major_version == '8.0') ? 4 : 1

        if cores <= 4
          default_purge_threads
        elsif cores <= 16
          [cores / 2, default_purge_threads].max
        else
          [8, default_purge_threads].max
        end
      end

      # Get appropriate SQL mode
      def osl_sql_modes
        major_version = osl_percona_version
        if major_version == '8.0'
          # 8.0 default: ONLY_FULL_GROUP_BY, STRICT_TRANS_TABLES, NO_ZERO_IN_DATE, NO_ZERO_DATE,
          # ERROR_FOR_DIVISION_BY_ZERO, NO_ENGINE_SUBSTITUTION
          # NO_AUTO_CREATE_USER is removed in 8.0.
          %w(ONLY_FULL_GROUP_BY STRICT_TRANS_TABLES NO_ZERO_IN_DATE NO_ZERO_DATE ERROR_FOR_DIVISION_BY_ZERO NO_ENGINE_SUBSTITUTION)
        else # 5.7
          %w(STRICT_TRANS_TABLES NO_ZERO_IN_DATE NO_ZERO_DATE ERROR_FOR_DIVISION_BY_ZERO NO_AUTO_CREATE_USER NO_ENGINE_SUBSTITUTION)
        end
      end

      # Get character set and collation
      def osl_char_settings
        major_version = osl_percona_version
        if major_version == '8.0'
          {
              character_set_server: 'utf8mb4',
              collation_server: 'utf8mb4_0900_ai_ci',
          }
        else # 5.7
          {
              character_set_server: 'utf8mb4',
              collation_server: 'utf8mb4_general_ci', # Common for 5.7
          }
        end
      end
    end
  end
end
Chef::DSL::Recipe.include ::OslMysql::Cookbook::Helpers
Chef::Resource.include ::OslMysql::Cookbook::Helpers
