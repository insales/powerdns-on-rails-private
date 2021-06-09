# frozen_string_literal: true

# https://stackoverflow.com/questions/58763542
#
# Fix for Postgres 12 error:
#
# PG::Error: ERROR:  invalid value for parameter "client_min_messages": "panic"
# HINT:  Available values: debug5, debug4, debug3, debug2, debug1, log, notice, warning, error.
# : SET client_min_messages TO 'panic'
#

# require 'active_record/connection_adapters/postgresql_adapter'

# module ActiveRecord
#   module ConnectionAdapters
#     class PostgreSQLAdapter
#       def set_standard_conforming_strings
#         old, self.client_min_messages = client_min_messages, 'warning'
#         execute('SET standard_conforming_strings = on', 'SCHEMA') rescue nil
#       ensure
#         self.client_min_messages = old
#       end
#     end
#   end
# end
