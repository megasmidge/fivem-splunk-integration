-- Event type definitions and schemas
EventTypes = {
    -- Player Events
    PLAYER_JOIN = 'player_join',
    PLAYER_LEAVE = 'player_leave',
    PLAYER_DEATH = 'player_death',
    PLAYER_REVIVE = 'player_revive',
    PLAYER_POSITION = 'player_position',
    PLAYER_CHAT = 'player_chat',
    
    -- Economy Events
    MONEY_CHANGE = 'money_change',
    ITEM_PURCHASE = 'item_purchase',
    ITEM_TRANSFER = 'item_transfer',
    JOB_PAYMENT = 'job_payment',
    
    -- Security Events
    ANTI_CHEAT_TRIGGER = 'anti_cheat_trigger',
    ADMIN_ACTION = 'admin_action',
    CHAT_VIOLATION = 'chat_violation',
    
    -- System Events
    RESOURCE_START = 'resource_start',
    RESOURCE_STOP = 'resource_stop',
    SERVER_PERFORMANCE = 'server_performance',
    DATABASE_QUERY = 'database_query',
    ERROR_EVENT = 'error_event'
}
