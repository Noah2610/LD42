require                 DIR[:src].join('Game')
require                 DIR[:src].join('LevelManager')
require                 DIR[:src].join('Player')
AdventureRL.require_dir DIR[:src].join('Blocks'), priority: 'Block'
require                 DIR[:src].join('Level')
require                 DIR[:src].join('Section')
AdventureRL.require_dir DIR[:src].join('Buttons')
AdventureRL.require_dir DIR[:src].join('Menus')
