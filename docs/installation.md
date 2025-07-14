# Quick Installation Guide

## 5-Minute Setup

### 1. Splunk Setup (2 minutes)
1. **Enable HEC**: Settings > Data Inputs > HTTP Event Collector > New Token
2. **Create Token**: Name it "FiveM-Integration", allow all indexes
3. **Copy Token**: Save the token value

### 2. FiveM Setup (3 minutes)
1. **Copy Resource**: Place `splunk-logger` in your resources folder
2. **Configure**: Copy `config.lua.example` to `config.lua` and add your Splunk URL and token
3. **Add to server.cfg**: `ensure splunk-logger`
4. **Restart Server**: Events will start flowing immediately

### 3. Verify
- Check FiveM console for: `[SplunkLogger] Splunk Logger initialized successfully`
- Search Splunk: `index=fivem_* | head 10`

## QBCore Integration (Optional)
1. **Copy Integration**: Place `qb-splunk-hooks` in your resources folder
2. **Add to server.cfg**: `ensure qb-splunk-hooks` (after qb-core and splunk-logger)
3. **Restart**: Rich gameplay events will now be logged

## Need Help?
- Check the [full configuration guide](configuration.md)
- Review [troubleshooting steps](../README.md#troubleshooting)
- Use `splunk-status` command in FiveM console for diagnostics
