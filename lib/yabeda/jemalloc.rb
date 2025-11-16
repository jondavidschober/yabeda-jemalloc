# frozen_string_literal: true

require 'yabeda/jemalloc/version'
require 'yabeda/jemalloc/ffi'

module Yabeda
  module Jemalloc
    Yabeda.configure do
      if ENV['LD_PRELOAD']&.include?('libjemalloc.so.2')
        gauge :jemalloc_mapped_bytes,
              comment: 'Total virtual bytes mapped by jemalloc'
        gauge :jemalloc_resident_bytes,
              comment: 'Resident bytes (RSS) that belong to jemalloc'
        gauge :jemalloc_active_bytes,
              comment: 'Bytes backing live allocations (user + internal)'
        gauge :jemalloc_allocated_bytes,
              comment: 'Bytes actually allocated by the app'
        collect do
          JemallocFFI.refresh!
          jemalloc_mapped_bytes.set({}, JemallocFFI.uint64('stats.mapped'))
          jemalloc_resident_bytes.set({}, JemallocFFI.uint64('stats.resident'))
          jemalloc_active_bytes.set({}, JemallocFFI.uint64('stats.active'))
          jemalloc_allocated_bytes.set({}, JemallocFFI.uint64('stats.allocated'))
        end
      end
    end
  end
end
