return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_better_performance = 1
    end,
  },

  { 
    "catppuccin/nvim", 
    name = "catppuccin", 
    lazy = false, 
    priority = 1000 
  },

  { 
    "folke/tokyonight.nvim", 
    lazy = false, 
    priority = 1000 
  },
  
  { 
    "ellisonleao/gruvbox.nvim", 
    lazy = false, 
    priority = 1000 
  },
}
