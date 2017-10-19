# Edidog
This tool easy copy graphs from Other Dashboars to New Dashboard.

## Installation

```
$ gem install edidog
```

## Usage

```
# Set Key
export DATADOG_API_KEY=xxxxxxxxxxxx
export DATADOG_APP_KEY=xxxxxxxxxxxx

# Get Dashboard List
> edidog list board

# Get Graph ID
> edidog list graph -B(--board) dashboard_id ...

# Create Timeboard
> edidog create <dashboard_name> [<graph_id> ...] -D(--description) "<description>" -V(--variables) key:default_value ...

# Update Timeboard Graphs
> edidog update <dashboard_id> -D(--delete) <graph_id>,... -A(--add) <graph_id>,...

# Delete Timeboard
> edidog delete <dashboard_id>

```
## Not Yet
* Support Screenboard
* -dry-run option

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/umisora/edidog. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Edidog project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/umisora/edidog/blob/master/CODE_OF_CONDUCT.md).


