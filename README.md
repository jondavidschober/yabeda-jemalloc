# Yabeda::Jemalloc

[![Gem Version](https://badge.fury.io/rb/yabeda-jemalloc.svg)](https://badge.fury.io/rb/yabeda-jemalloc)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

A [Yabeda](https://github.com/yabeda-rb/yabeda) plugin that exposes [jemalloc](http://jemalloc.net/) memory allocation statistics for Ruby applications. This gem uses FFI to interface with jemalloc's `mallctl` API and exports key memory metrics to Prometheus or other monitoring systems.

## Why Use This Gem?

Jemalloc is a high-performance memory allocator that provides detailed memory statistics. When running Ruby applications with jemalloc, you can gain valuable insights into:

- **Memory fragmentation**: Understand the difference between allocated vs. resident memory
- **Virtual memory usage**: Track total mapped memory by jemalloc
- **Active allocations**: Monitor memory backing live allocations

This is especially useful for production Ruby applications where memory management and leak detection are critical.

## Requirements

- Ruby 2.6 or higher
- [jemalloc](http://jemalloc.net/) installed and preloaded via `LD_PRELOAD`
- [Yabeda](https://github.com/yabeda-rb/yabeda) gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yabeda-jemalloc'
gem 'yabeda-prometheus' # or another exporter
```

And then execute:

```bash
$ bundle install
```

## Usage

### 1. Install jemalloc

First, ensure jemalloc is installed on your system:

**Ubuntu/Debian:**
```bash
sudo apt-get install libjemalloc2
```

**macOS:**
```bash
brew install jemalloc
```

**Alpine Linux:**
```bash
apk add jemalloc
```

### 2. Configure Your Application

The gem automatically registers metrics when jemalloc is detected. Simply require it in your application:

```ruby
require 'yabeda/jemalloc'
```

For Rails applications, add to your `config/initializers/yabeda.rb`:

```ruby
require 'yabeda/prometheus'
require 'yabeda/jemalloc'
```

### 3. Run with jemalloc Preloaded

You need to preload jemalloc when starting your Ruby application:

```bash
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 bundle exec rails server
```

Or for other Ruby applications:

```bash
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 ruby your_app.rb
```

**Docker Example:**

```dockerfile
FROM ruby:3.3
RUN apt-get update && apt-get install -y libjemalloc2
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
# ... rest of your Dockerfile
```

### 4. Access Metrics

If using `yabeda-prometheus`, metrics will be available at your configured metrics endpoint (typically `/metrics`):

```
# HELP jemalloc_mapped_bytes Total virtual bytes mapped by jemalloc
# TYPE jemalloc_mapped_bytes gauge
jemalloc_mapped_bytes 2147483648

# HELP jemalloc_resident_bytes Resident bytes (RSS) that belong to jemalloc
# TYPE jemalloc_resident_bytes gauge
jemalloc_resident_bytes 1073741824

# HELP jemalloc_active_bytes Bytes backing live allocations (user + internal)
# TYPE jemalloc_active_bytes gauge
jemalloc_active_bytes 536870912

# HELP jemalloc_allocated_bytes Bytes actually allocated by the app
# TYPE jemalloc_allocated_bytes gauge
jemalloc_allocated_bytes 268435456
```

## Exposed Metrics

| Metric Name | Type | Description |
|-------------|------|-------------|
| `jemalloc_mapped_bytes` | gauge | Total number of bytes in active extents mapped by the allocator |
| `jemalloc_resident_bytes` | gauge | Maximum number of bytes in physically resident data pages mapped by the allocator |
| `jemalloc_active_bytes` | gauge | Total number of bytes in active pages allocated by the application |
| `jemalloc_allocated_bytes` | gauge | Total number of bytes allocated by the application |

### Understanding the Metrics

- **Mapped**: Virtual memory allocated by jemalloc (highest number)
- **Resident**: Physical memory (RAM) actually used (RSS)
- **Active**: Memory pages with at least one allocation
- **Allocated**: Memory requested by your application (lowest number)

The difference between these metrics helps identify memory fragmentation and over-allocation issues.

## Configuration

The gem automatically configures itself when jemalloc is detected via `LD_PRELOAD`. No additional configuration is required.

If jemalloc is not preloaded, the gem will silently skip metric registration, allowing you to safely include it in environments where jemalloc may not be available.

## Troubleshooting

### Metrics not appearing?

1. Verify jemalloc is preloaded:
   ```bash
   echo $LD_PRELOAD  # should include libjemalloc.so.2
   ```

2. Check if jemalloc is actually being used:
   ```bash
   ldd $(which ruby) | grep jemalloc
   ```

3. Ensure Yabeda is properly configured with an exporter (e.g., `yabeda-prometheus`)

### Wrong jemalloc path?

The path to `libjemalloc.so.2` varies by system. Find it with:

```bash
find /usr -name "libjemalloc.so*" 2>/dev/null
```

Then use the full path in your `LD_PRELOAD`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jondavidschober/yabeda-jemalloc.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Created by [Jon David Schober](https://github.com/jondavidschober) at [Datavine](https://getdatanamic.com).

## See Also

- [Yabeda](https://github.com/yabeda-rb/yabeda) - Extensible framework for collecting metrics
- [jemalloc](http://jemalloc.net/) - General purpose malloc implementation
- [yabeda-prometheus](https://github.com/yabeda-rb/yabeda-prometheus) - Prometheus exporter for Yabeda
- [Observability is the Eyes and Ears of a Service](dev.datavine.com/observability-is-the-eyes-and-ears-of-a-service)