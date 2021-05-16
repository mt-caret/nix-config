{ isNixOS, pkgs, ... }:
let
  unstable = (import ../nixpkgs).unstable;
in
{
  home.packages = with pkgs; [
    fzf
    rnix-lsp
    nixpkgs-fmt
    golint
    nodePackages.bash-language-server
  ] ++ (
    with unstable; [
      gotools
      gopls
    ]
  );

  programs.go.enable = isNixOS;
  programs.neovim = {
    enable = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;

    plugins = with pkgs.vimPlugins; [
      vim-nix
      coc-nvim
      #LanguageClient-neovim
      #deoplete-nvim
      #fzf-vim
    ];

    extraConfig = ''
      let mapleader = " " " Leader

      set backspace=2 " Backspace deletes like most programs in insert mode

      set ruler " show the cursor position all the time
      set showcmd " display incomplete commands
      set incsearch
      set laststatus=2 " Always display the status line

      set colorcolumn=80,160,240
      highlight ColorColumn ctermbg=88

      set number
      set numberwidth=4

      set tabstop=2
      set shiftwidth=2
      set shiftround
      set expandtab

      nnoremap <C-]> g<C-]>

      set list listchars=tab:»·,trail:·,nbsp:·

      "set mouse=a

      tnoremap <Esc> <C-\><C-n> " Esc works in :term

      imap <C-f> <C-x><C-o>

      filetype plugin indent on
      syntax enable
      colorscheme default

      set nobackup
      set nowritebackup
      set cmdheight=2
      set updatetime=300
      set shortmess+=c
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)
      nnoremap <silent> K :call <SID>show_documentation()<CR>
      function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
          execute 'h '.expand('<cword>')
        else
          call CocAction('doHover')
        endif
      endfunction
      autocmd CursorHold * silent call CocActionAsync('highlight')
      augroup mygroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
      augroup end
      highlight CocFloating ctermbg=238

      au FileType go set noexpandtab
      au FileType go set shiftwidth=4
      au FileType go set softtabstop=4
      au FileType go set tabstop=4
      autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')
      autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.format')
    '';
  };

  xdg.configFile."nvim/coc-settings.json".text = builtins.toJSON rec {
    languageserver = {
      golang = {
        command = "gopls";
        args = [ "serve" ];
        disableWorkspaceFolders = true;
        filetypes = [ "go" ];
        rootPatterns = [ "go.mod" ];
      };
      haskell = {
        command = "haskell-language-server-wrapper";
        args = [ "--lsp" ];
        filetypes = [ "hs" "lhs" "haskell" ];
        rootPatterns = [ "stack.yaml" "cabal.config" "package.yaml" ];
        initializationOptions.languageServerHaskell = {
          formattingProvider = "ormolu";
          hlintOn = true;
        };
      };
      nix = {
        command = "${pkgs.rnix-lsp}/bin/rnix-lsp";
        filetypes = [ "nix" ];
      };
      ocaml = {
        command = "ocamllsp";
        filetypes = [ "ocaml" ];
      };
      rust = {
        command = "rust-analyzer";
        filetypes = [ "rust" ];
        rootPatterns = [ "Cargo.toml" ];
        initializationOptions = {
          clippy_preference = "on";
        };
      };
      # TODO: check if this really is working
      bash = {
        command =
          "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
        args = [ "start" ];
        filetypes = [ "sh" ];
        ignoredRootPaths = [ "~" ];
      };
    };
    coc.preferences.formatOnSaveFiletypes = builtins.attrNames languageserver;
  };
}
