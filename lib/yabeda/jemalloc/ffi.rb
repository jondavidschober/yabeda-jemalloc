# frozen_string_literal: true

require 'ffi'
module Yabeda::Jemalloc::JemallocFFI
  if ENV['LD_PRELOAD']&.include?('libjemalloc.so.2')
    extend FFI::Library
    ffi_lib 'libjemalloc.so.2' # uses the already-preloaded jemalloc.so

    attach_function :mallctl, %i[string pointer pointer pointer size_t], :int

    SIZE_T = FFI::Type::ULONG_LONG.size # works on 64-bit only

    def self.refresh!
      epoch = FFI::MemoryPointer.new(:ulong_long)
      sz    = FFI::MemoryPointer.new(:size_t).write_ulong_long(SIZE_T)
      mallctl('epoch', epoch, sz, epoch, SIZE_T) # epoch++ refreshes stats
    end

    def self.uint64(name)
      buf = FFI::MemoryPointer.new(:ulong_long)
      sz  = FFI::MemoryPointer.new(:size_t).write_ulong_long(SIZE_T)
      mallctl(name, buf, sz, nil, 0)
      buf.read_ulong_long
    end

    def self.dump(path)
      path_ptr = FFI::MemoryPointer.from_string(path)
      path_arg = FFI::MemoryPointer.new(:pointer)
      path_arg.write_pointer(path_ptr)
      ret = Jemalloc.mallctl('prof.dump', nil, nil, path_arg, FFI::Type::POINTER.size)

      raise "mallctl failed with error code #{ret}" if ret != 0

      puts "Heap profile dumped to #{path || 'default path'}"
    end
  end
end
