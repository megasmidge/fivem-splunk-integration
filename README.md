# FiveM Splunk Integration

Real-time analytics integration between FiveM servers and Splunk for monitoring player behavior, server performance, and security events.

## 🚀 Features

- **Real-time Event Streaming** - Direct HTTP Event Collector (HEC) integration
- **Intelligent Batching** - Automatic event queuing and batching for optimal performance
- **Retry Logic** - Robust error handling with automatic retry mechanisms
- **Multi-Index Routing** - Smart data segregation by event type for better analytics
- **Player Lifecycle Tracking** - Monitor joins, leaves, deaths, and position data
- **Economy Monitoring** - Track money transactions and item transfers
- **Security Events** - Anti-cheat triggers and admin action logging
- **Performance Metrics** - Server health and resource usage monitoring
- **QBCore Integration** - Rich roleplay server event collection

## 📊 Data Architecture

### Splunk Indexes
- **fivem_players** - Player lifecycle and character data
- **fivem_economy** - Financial transactions and purchases
- **fivem_security** - Security events and crime detection
- **fivem_system** - Server performance and system metrics
- **fivem_tracking** - High-volume position and movement data
- **fivem_social** - Chat and social interactions

### Event Types
- Player Events: joins, leaves, deaths, character creation
- Economy Events: money changes, purchases, transfers, vehicle sales
- Job Events: duty changes, paychecks, promotions
- Crime Events: arrests, fines, drug deals, robberies
- Vehicle Events: spawning, impounding, modifications
- Medical Events: treatments, transports, EMS responses

## 🔧 Quick Start

### 1. Install Core Logger (5 minutes)
```bash
# Copy to your FiveM server
cp -r resources/splunk-logger /path/to/your/fivem/resources/

# Configure
cp resources/splunk-logger/config.lua.example resources/splunk-logger/config.lua
# Edit config.lua with your Splunk details

# Add to server.cfg
echo "ensure splunk-logger" >> server.cfg
```

### 2. QBCore Integration (Optional)
```bash
# Copy QBCore hooks
cp -r examples/qbcore-integration/qb-splunk-hooks /path/to/your/fivem/resources/

# Add to server.cfg after qb-core
echo "ensure qb-splunk-hooks" >> server.cfg
```

### 3. Verify Installation
- Check console: `[SplunkLogger] Splunk Logger initialized successfully`
- Search Splunk: `index=fivem_* | head 10`
- Use admin command: `splunk-status`

## 📖 Documentation

- **[Installation Guide](docs/installation.md)** - Quick setup instructions
- **[Configuration Guide](docs/configuration.md)** - Performance tuning and security
- **[QBCore Integration](examples/qbcore-integration/docs/installation.md)** - Roleplay server setup

## 🎯 Usage Examples

### Basic Event Logging
```lua
-- Log custom player event
exports['splunk-logger']:LogPlayerEvent('player_achievement', source, {
    achievement_name = 'first_car_purchase',
    achievement_value = 50000
})

-- Log system event
exports['splunk-logger']:LogSystemEvent('maintenance_started', {
    maintenance_type = 'database_cleanup',
    estimated_duration = 1800
})
```

### QBCore Integration Examples
```lua
-- Automatic money transaction logging
RegisterNetEvent('QBCore:Server:OnMoneyChange', function(src, moneyType, amount, reason)
    -- Automatically logged by qb-splunk-hooks
end)

-- Custom business event
RegisterNetEvent('qb-businesses:server:purchaseProperty', function(propertyId, price)
    exports['splunk-logger']:LogPlayerEvent('property_purchase', source, {
        property_id = propertyId,
        purchase_price = price,
        business_type = 'real_estate'
    })
end)
```

## 🔧 Configuration

### Minimal Setup
```lua
Config.Splunk = {
    hec_url = "https://your-splunk.com:8088/services/collector",
    token = "your-hec-token-here"
}
```

### Production Setup with Performance Tuning
```lua
Config.Splunk = {
    hec_url = "https://your-splunk.com:8088/services/collector",
    token = "your-hec-token-here",
    timeout = 10000,
    verify_ssl = true
}

Config.Batching = {
    max_batch_size = 50,        -- Tune based on server load
    flush_interval = 5000,      -- 5 seconds
    max_queue_size = 1000,      -- Adjust for memory usage
    retry_attempts = 3,
    retry_delay = 2000
}
```

## 📈 Performance & Scaling

### High-Volume Servers (100+ players)
- Increase batch sizes to reduce HTTP overhead
- Decrease flush intervals for real-time data
- Consider separate Splunk indexers for high-volume data

### Resource Usage
- **Memory**: ~50-100MB for queue management
- **CPU**: <1% overhead with proper batching
- **Network**: Configurable based on event volume

## 🛡️ Security

### Data Protection
- Automatic sanitization of sensitive fields (passwords, tokens, API keys)
- HTTPS-only communication with Splunk
- Configurable SSL verification

### Access Control
- Separate indexes for different data sensitivity levels
- Token-based authentication with Splunk HEC
- Granular event type filtering

## 🔍 Monitoring & Troubleshooting

### Health Checks
```bash
# FiveM console command
splunk-status

# Expected output
=== Splunk Logger Status ===
Queue Size: 0
Events Sent: 1,245
Events Failed: 0
Batches Sent: 25
```

### Common Issues
- **No events in Splunk**: Check HEC token permissions and network connectivity
- **Queue backing up**: Increase batch size or decrease flush interval
- **High memory usage**: Reduce max queue size or increase flush frequency

### Debug Mode
```lua
Config.Events = {
    enable_debug_logging = true  -- Enable detailed console output
}
```

## 🎯 Built for .conf 2026

This project demonstrates real-world Splunk integration with gaming platforms and showcases:
- **Enterprise Data Architecture** - Multi-index routing and data governance
- **Real-time Analytics** - Live player behavior and server monitoring
- **Security Use Cases** - Fraud detection and anti-cheat integration
- **Custom Integration Patterns** - How to connect any application to Splunk

## 🤝 Contributing

This is an open-source project designed to help the FiveM and Splunk communities. Contributions welcome!

### Development Setup
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Test with local FiveM server
4. Submit pull request

### Integration Examples
We welcome integration examples for other FiveM frameworks:
- ESX Framework
- vRP Framework
- Custom frameworks

## 📄 License

MIT License - See LICENSE file for details

## 🔗 Links

- **Splunk Documentation**: [docs.splunk.com](https://docs.splunk.com)
- **FiveM Documentation**: [docs.fivem.net](https://docs.fivem.net)
- **QBCore Framework**: [github.com/qbcore-framework](https://github.com/qbcore-framework)

---

**Questions?** Open an issue or check the documentation in the `docs/` folder.