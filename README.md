# Facebook Extension for Defold

This extension wraps Facebook SDK for iOS (5.11.0). On other platforms this extension provides stub functions.

## Setup

Add Facebook App Id and Display Name to the `game.project` file.

```
[facebook]
app_id = 12345
display_name = Defold Facebook
```

# API reference

## facebook.init(params)

Call this function before invoking any other functions.

### `params` reference

- `auto_log_app_events`, boolean, optional. Default is `false`.
- `advertiser_id_collection`, boolean, optional. Default is `false`.

### Syntax

```language-lua
facebook.init{
	auto_log_app_events = true,
	advertiser_id_collection = true
}
```
___
## facebook.track_event(params)

Track an event via the SDK.

### `params` reference

- `name`, string, required. Event name.
- `value`, number, optional. Value.
- `params`, table, optional. A key-value set of extra event parameters.

### Syntax

```language-lua
facebook.track_event{
	name = 'event_name',
	value = 1,
	params = {
		key1 = 'value1',
		key2 = 'value2'
	}
}
```
