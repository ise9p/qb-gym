# QBCore Gym System

A comprehensive gym system for QBCore Framework with membership management, multiple exercises, and buff system integration.

## 🌟 Features

- Membership System
  - Purchase memberships
  - Extend existing memberships
  - Automatic expiration
  - Item-based verification

- Exercise Activities
  - Treadmill
  - Yoga
  - Weight Lifting
  - Pull-ups

- Buff System Integration
  - Health buffs
  - Stamina improvements
  - Stress reduction

- Management Features
  - Gym funds tracking
  - Owner withdrawal system
  - Discord webhook logging

## 📋 Dependencies

- QBCore Framework
- oxmysql
- qb-target/ox_target
- qb-input/ox_lib
- qb-menu/ox_lib
- ps-buffs
- ox_inventory (for shop system)

## ⚙️ Installation

1. Import the SQL:
```sql
CREATE TABLE IF NOT EXISTS gym_memberships (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    months INT NOT NULL,
    price INT NOT NULL,
    expiry BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS `gym_funds` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `amount` INT NOT NULL DEFAULT 0
);

INSERT INTO `gym_funds` (`id`, `amount`) VALUES (1, 0);
```

2. Add to qb-core/shared/items.lua:
```lua
['gym_membership'] = {
    ['name'] = 'gym_membership',
    ['label'] = 'Gym Membership',
    ['weight'] = 0,
    ['type'] = 'item',
    ['image'] = 'gym_membership.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Gym Membership Card'
}
```

3. Copy the gym_membership.png to your inventory images folder

4. Add to server.cfg:
```cfg
ensure qb-gym
```

## 🔧 Configuration

Edit config.lua to customize:
- UI System (QB/OX)
- Membership prices
- Exercise locations
- Buff durations and effects
- Discord webhook settings
- Payment methods

## 💪 Exercise Types

1. **Treadmill**
   - Improves stamina
   - Running animation
   - 30-second workout

2. **Yoga**
   - Reduces stress
   - Improves health
   - Peaceful animations

3. **Weight Lifting**
   - Increases strength
   - Uses barbell prop
   - Health improvements

4. **Pull-ups**
   - Stamina boost
   - Strength increase
   - Advanced workout

## 📝 Discord Logging

The system logs:
- Membership purchases
- Membership extensions
- Membership expirations
- Fund withdrawals
- System errors

## 🎮 Usage

1. Visit the gym location
2. Purchase a membership
3. Use any exercise equipment
4. Receive buffs upon completion
5. Extend membership when needed

## 💼 Owner Features

- Access funds dashboard
- Withdraw accumulated money
- View transaction history
- Manage gym operations

## ⚠️ Support

For issues and support:
- Create an issue on GitHub
- Join our Discord server
- Check documentation

## 📜 License

This project is licensed under MIT License

## 🤝 Credits

- Original development by YourName
- QBCore Framework Team
- Contributors and testers



