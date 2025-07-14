# Configuration Guide

## Basic Configuration

### Minimal Setup
```lua
Config.Splunk = {
    hec_url = "https://your-splunk.com:8088/services/collector",
    token = "your-token-here"
}
```

### Production Setup
```lua
Config.Splunk = {
    hec_url = "https://your-splunk.com:8088/services/collector", 
    token = "your-token-here",
    timeout = 10000,
    verify_ssl = true
}

Config.Batching = {
    max_batch_size = 50,
    flush_interval = 5000,
    max_queue_size = 1000,
    retry_attempts = 3,
    retry_delay = 2000
}

Config.Server = {
    id = GetConvar('sv_hostname', 'my-server'),
    environment = GetConvar('sv_environment', 'production')
}
```

## Performance Tuning

### High-Volume Server (100+ players)
- Increase `max_batch_size` to 100
- Decrease `flush_interval` to 3000
- Increase `player_position_interval` to 60000

### Low-Volume Server (<20 players)  
- Decrease `max_batch_size` to 20
- Increase `flush_interval` to 10000
- Standard `player_position_interval` of 30000

## Security Considerations

### Sensitive Data
The logger automatically removes sensitive fields:
- `password`
- `token` 
- `api_key`

### Network Security
- Use HTTPS for HEC endpoints
- Set `verify_ssl = true` in production
- Restrict HEC token permissions to specific indexes

## Environment Variables

Use convars for deployment flexibility:

In server.cfg:
```
set splunk_hec_url "https://your-splunk.com:8088/services/collector"
set splunk_token "your-token"
set sv_environment "production"
```

In config.lua:
```lua
Config.Splunk = {
    hec_url = GetConvar('splunk_hec_url', 'https://localhost:8088/services/collector'),
    token = GetConvar('splunk_token', ''),
}
```