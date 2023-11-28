-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local Config = require("lazy.core.config")
Config.options.checker.frequency = 60 * 60 * 24 -- once per day
