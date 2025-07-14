# QBCore Integration Setup

## Prerequisites
- Working FiveM server with QBCore framework
- `splunk-logger` resource installed and configured
- QBCore version 1.0+ recommended

## Installation Steps

### 1. Copy Integration Resource
```bash
cp -r examples/qbcore-integration/qb-splunk-hooks /path/to/your/fivem/resources/
```

### 2. Update server.cfg
```cfg
# Ensure proper load order
ensure qb-core
ensure splunk-logger
ensure qb-splunk-hooks
```

### 3. Restart Server
The integration will automatically start logging QBCore events.

## What Gets Logged

### Player Events
- Character creation and selection
- Player joins and leaves with full character data
- Deaths and revivals with location data

### Economy Events  
- All money transactions (cash, bank, crypto)
- Store purchases with location tracking
- Player-to-player transfers
- Vehicle purchases and sales
- ATM transactions

### Job System
- Job changes and promotions
- Duty clock in/out
- Paycheck distribution
- Boss menu actions

### Crime & Security
- Police arrests with charges
- Fines and tickets
- Drug transactions
- Store and bank robberies
- Weapon usage tracking

### Vehicles
- Vehicle spawning from garages
- Impounding by police
- Modifications at customs shops
- Player-to-player vehicle sales

### Medical/EMS
- Medical treatments
- Hospital transports
- EMS response tracking

## Customization

### Disable Specific Event Types
Edit the integration files to comment out unwanted events:
```lua
-- RegisterNetEvent('QBCore:Server:OnMoneyChange', function(src, moneyType, amount, reason)
--     -- Commented out to disable money logging
-- end)
```

### Add Custom Events
Create new event handlers in the integration files:
```lua
RegisterNetEvent('my-custom:server:event', function(data)
    local src = source
    exports['splunk-logger']:LogPlayerEvent('custom_event', src, {
        custom_data = data,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    })
end)
```

## Verification

### Check Event Flow
1. Join the server with a character
2. Perform some actions (buy items, change jobs, etc.)
3. Search Splunk:
```splunk
index=fivem_* sourcetype="fivem:*" 
| stats count by sourcetype
```

### Expected Event Types
- `fivem:player:lifecycle` - Joins, leaves, character creation
- `fivem:economy:money` - Money transactions
- `fivem:economy:transaction` - Purchases
- `fivem:player:combat` - Deaths, revivals
- `fivem:security:*` - Crime and police events

## Troubleshooting

### No QBCore Events
1. Verify QBCore is loaded before the integration
2. Check for Lua errors in F8 console
3. Ensure QBCore exports are accessible

### Missing Event Data
1. Update to latest QBCore version
2. Check if event names have changed in QBCore updates
3. Review integration files for compatibility