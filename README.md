# Memory Hunter
Basic memory leak detection for Ruby applications.
The way we used to analyse memory usage is based on [this blog post](http://blog.skylight.io/hunting-for-leaks-in-ruby/)

## Usage

### Are we leaking?

Hit an API or a page repeatedly and see if the memory usage keep going up without converging to a certain amount.

- Copy `request.default.yml` to `request.yml`, and edit the request parameters.
- run `$ ruby profile.rb <PID_OF_SERVER>`

### Dump object space

Dump object space of your server process into a file:

- Add the following lines into your server process:

```ruby
require 'rbtrace'
require 'objspace'
ObjectSpace.trace_object_allocations_start
```

- run `$ ruby dump.rb <PID_OF_SERVER> <OUTPUT_FILENAME>`


### Analyse object space dump files

We need three files to analyse memory usage.

- run `$ ruby main <DUMP_FILE1> <DUMP_FILE2> <DUMP_FILE3>`

which will produce two suspect leaking lists sorted by memsize and bytesize, respectively.


## Testing

- install dependencies by `$ bundle install`
- run `$ bundle exec rspec`
