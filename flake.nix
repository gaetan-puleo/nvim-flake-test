{ 
  description = "My neovim config";
  inputs.nixvim.url = "github:nix-community/nixvim";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # plugins
  inputs.nvim-window-picker-src = {
    url = "github:s1n7ax/nvim-window-picker";
    flake = false;
  };

  inputs.nvim-comment-src = {
    url = "github:terrortylor/nvim-comment";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    nixvim,
    flake-utils,
    nvim-window-picker-src,
    nvim-comment-src
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages."${system}";
      nvim = nixvim.legacyPackages."${system}".makeNixvim {
        extraFiles = {
          lua = "./lua";
        };
        extraConfigLuaPost = "" + 
        "vim.api.nvim_command('set runtimepath^=${self}') \n" +
        "vim.api.nvim_command('let &packpath = &runtimepath') \n" +
        ''
        if(not vim.g.vscode) then
          require('settings/global')
          require('settings/mapping')
          require('plugin-list')

        end
        ''+

        ''
        if(vim.g.vscode) then
          require('settings/global')
          require('settings/mapping')
        end
        '' +
        # "dofile('${self}/lua/test.lua')" +
        "vim.wo.numberwidth = 4 -- columns number in gutter" +

        builtins.readFile "${self}/config/plugins/nvim-comment.lua";
        
        # settings
        globals.mapleader = " "; # Sets the leader key to space
        globals.maplocalleader = " "; # Sets the leader key to space
        options = import "${self}/config/options.nix";
        globals.cursorholdUpdatetime = 100;


        maps = import "${self}/config/maps.nix";
        # colorscheme
        colorschemes.catppuccin.enable = true;
        colorschemes.catppuccin.flavour = "mocha";

        # lsp
        plugins.lsp.enable = true ;
        
        # statusline
        plugins.lightline.enable = true;

        # fold code
        plugins.nvim-ufo = import "${self}/config/plugins/nvim-ufo.nix";


        # treesitter
        plugins.treesitter.enable = true;      

        plugins.ts-autotag.enable = true;
        plugins.treesitter-refactor.enable = true;
        plugins.ts-context-commentstring.enable = true;

        # telescope
        plugins.telescope = import "${self}/config/plugins/telescope.nix";


        # plugins
	      plugins.mini = import "${self}/config/plugins/mini.nix";

        # git
	      plugins.gitsigns = import "${self}/config/plugins/gitsigns.nix";


        # filetree
        plugins.neo-tree.enable = true;

        extraPlugins = [
          (pkgs.vimUtils.buildVimPlugin {
            name = "nvim-window-picker";
            src = nvim-window-picker-src;
          })

          (pkgs.vimUtils.buildVimPlugin {
            name = "nvim-comment";
            src = nvim-comment-src;
            buildPhase = ":"; # ignore build phase
          })
        ];

        # neovim dependancies
        extraPackages = [
          pkgs.ripgrep
        ];
      };
    in {
      packages = {
        inherit nvim;
        default = nvim;
      };
    });
}
