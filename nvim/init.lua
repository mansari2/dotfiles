-- ==========================================================
-- Neovim Config — single file, lazy.nvim plugin manager
-- ==========================================================

-- Leader key (must be set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw (neo-tree replaces it)
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- ── Core settings ─────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 8
vim.opt.cursorline = true
vim.opt.undofile = true
vim.opt.swapfile = false

-- ── Bootstrap lazy.nvim ───────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ───────────────────────────────────────────────
require("lazy").setup({
  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- File tree (right side)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
        default_component_configs = {
          git_status = {
            symbols = {
              added     = "+",
              modified  = "~",
              deleted   = "-",
              renamed   = "r",
              untracked = "?",
              ignored   = ".",
              unstaged  = "U",
              staged    = "S",
              conflict  = "!",
            },
          },
        },
        window = { position = "right", width = 35 },
        filesystem = {
          follow_current_file = { enabled = true },
          filtered_items = { hide_dotfiles = false },
          hijack_netrw_behavior = "open_current",
          use_libuv_file_watcher = true, -- Auto-refresh on file changes
        },
        event_handlers = {
          -- Auto-refresh when focus returns to neovim
          {
            event = "vim_buffer_enter",
            handler = function()
              require("neo-tree.sources.manager").refresh("filesystem")
            end,
          },
        },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle position=right<cr>", { desc = "Toggle file tree" })
      vim.keymap.set("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Reveal current file in tree" })
      vim.keymap.set("n", "<leader>r", function()
        require("neo-tree.sources.manager").refresh("filesystem")
      end, { desc = "Refresh file tree" })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
      pcall(telescope.load_extension, "fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Search file contents" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      -- Git telescope pickers
      vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
      vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
    end,
  },

  -- Treesitter (parser installer; highlighting is built into nvim 0.11+)
  -- Install parsers: :TSInstall lua typescript python etc.
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})
    end,
  },

  -- Which-key (shows keybinding hints)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup()
      wk.add({
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "Code" },
        { "<leader>h", group = "Hunk" },
        { "<leader>m", group = "Markdown" },
        { "<leader>i", group = "Inlay" },
      })
    end,
  },

  -- Git signs in gutter + inline blame
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = false,
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local opts = function(desc)
            return { buffer = bufnr, desc = desc }
          end
          -- Navigation between hunks
          vim.keymap.set("n", "]h", gs.next_hunk, opts("Next hunk"))
          vim.keymap.set("n", "[h", gs.prev_hunk, opts("Prev hunk"))
          -- Hunk actions
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts("Preview hunk"))
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk, opts("Stage hunk"))
          vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, opts("Undo stage hunk"))
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk, opts("Reset hunk"))
          vim.keymap.set("n", "<leader>hd", gs.diffthis, opts("Diff this file"))
          vim.keymap.set("n", "<leader>hb", gs.toggle_current_line_blame, opts("Toggle line blame"))
        end,
      })
    end,
  },

  -- Status line (shows git branch + diff counts)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "catppuccin" },
        sections = {
          lualine_b = { "branch", "diff", "diagnostics" },
        },
      })
    end,
  },

  -- Seamless tmux/nvim pane navigation
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP completions
      "hrsh7th/cmp-buffer",       -- Buffer completions
      "hrsh7th/cmp-path",         -- Path completions
      "L3MON4D3/LuaSnip",         -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
      "rafamadriz/friendly-snippets", -- Collection of snippets
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
      -- Integrate with cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Surround text objects (add/delete/change surrounding quotes, brackets, etc.)
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    ft = { "markdown" },
    config = function()
      vim.g.mkdp_auto_close = 0
      vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle Markdown Preview" })
    end,
  },

  -- LSP (provides default server configs for vim.lsp.config)
  { "neovim/nvim-lspconfig", lazy = true },
}, {
  -- lazy.nvim options
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },
})

-- ── LSP (native vim.lsp.config, nvim 0.11+) ──────────────
-- Configure diagnostics display
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = "if_many",
  },
  float = {
    source = "always",
    border = "rounded",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Lua LSP config
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})

-- Python LSP config (enhanced for better type hints)
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

vim.lsp.enable({ "ts_ls", "pyright", "lua_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    -- Inlay hints (show type hints inline for Python)
    if vim.lsp.inlay_hint then
      vim.keymap.set("n", "<leader>ih", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, { buffer = ev.buf, desc = "Toggle inlay hints" })
    end
  end,
})

-- ── Lazygit (floating terminal) ───────────────────────────
vim.keymap.set("n", "<leader>gg", function()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = vim.o.columns - 2
  local height = vim.o.lines - 2
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen("lazygit", {
    on_exit = function()
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Open lazygit" })

-- ── Built-in manual (floating window) ─────────────────────
vim.keymap.set("n", "<leader>?", function()
  local lines = {
    "  PANE NAVIGATION (tmux + neovim)                     ",
    "  --------------------------------------------------  ",
    "    Ctrl+h/j/k/l      Move between panes              ",
    "    Ctrl+a d           Detach (reattach with: dev)     ",
    "                                                      ",
    "  TMUX (prefix = Ctrl+a)                              ",
    "  --------------------------------------------------  ",
    "    Ctrl+a c           Switch sessions (arrow keys)    ",
    "    Ctrl+a C           New dev session (same dir)      ",
    "    Ctrl+a S           Fuzzy find sessions (fzf)       ",
    "    Ctrl+a |           Vertical split pane             ",
    "    Ctrl+a -           Horizontal split pane           ",
    "    Ctrl+a z           Toggle pane fullscreen          ",
    "    Ctrl+a H/J/K/L     Resize pane                     ",
    "    Ctrl+a [           Copy mode (vi keys, q to exit)  ",
    "    dev -l             List all sessions (in shell)    ",
    "                                                      ",
    "  FILE TREE (Space e toggles, tree on the right)      ",
    "  --------------------------------------------------  ",
    "    Enter              Open file                       ",
    "    a                  Create file (/ for folder)      ",
    "    d                  Delete                          ",
    "    r                  Rename                          ",
    "    c / x / p          Copy / cut / paste              ",
    "    m                  Move                            ",
    "    H                  Toggle hidden files             ",
    "    /                  Filter / search                 ",
    "                                                      ",
    "  FIND (fuzzy search)                                 ",
    "  --------------------------------------------------  ",
    "    Space ff           Find files by name              ",
    "    Space fg           Search file contents (grep)     ",
    "    Space fb           Switch between open buffers     ",
    "                                                      ",
    "  GIT                                                 ",
    "  --------------------------------------------------  ",
    "    Space gg           Open lazygit (full git TUI)     ",
    "    Space gs           Git status (modified files)     ",
    "    Space gc           Git commit log                  ",
    "    Space gb           Git branches                    ",
    "    Space hb           Toggle line blame               ",
    "    Space hp           Preview hunk diff               ",
    "    Space hs / hu      Stage / undo stage hunk         ",
    "    Space hr           Reset hunk (discard change)     ",
    "    Space hd           Diff current file               ",
    "    ] h / [ h          Next / prev changed hunk        ",
    "                                                      ",
    "  CODE (LSP)                                          ",
    "  --------------------------------------------------  ",
    "    gd                 Go to definition                ",
    "    gr                 Find references                 ",
    "    K                  Hover docs                      ",
    "    Space ca           Code action (quick fix)         ",
    "    Space rn           Rename symbol                   ",
    "                                                      ",
    "  EDITING                                             ",
    "  --------------------------------------------------  ",
    "    i                  Start typing (insert mode)      ",
    "    Esc                Back to normal mode              ",
    "    Ctrl+s             Save file                       ",
    "    Space w            Save file                       ",
    "    Space x            Close file (not neovim)         ",
    "    Space q            Quit neovim                     ",
    "    u / Ctrl+r         Undo / redo                     ",
    "    V then J/K         Move lines up/down              ",
    "    Ctrl+d / Ctrl+u    Half-page scroll                ",
    "    gcc                Toggle line comment             ",
    "    gc (visual)        Toggle comment on selection     ",
    "    Tab / S-Tab        Next/prev autocomplete item     ",
    "    ys<motion><char>   Surround with char (e.g. ysiw\") ",
    "    ds<char>           Delete surrounding char         ",
    "    cs<old><new>       Change surrounding char         ",
    "                                                      ",
    "  MARKDOWN (in .md files)                             ",
    "  --------------------------------------------------  ",
    "    Space mp           Toggle markdown preview         ",
    "                                                      ",
    "  PYTHON                                              ",
    "  --------------------------------------------------  ",
    "    Space ih           Toggle inlay type hints         ",
    "    Space d            Show diagnostic details         ",
    "    ] d / [ d          Next / prev diagnostic          ",
    "                                                      ",
    "  TIP: Don't use :wq  -- it exits neovim!             ",
    "  Use Ctrl+s to save, Space x to close a file.        ",
    "                                                      ",
    "  QUICK START                                         ",
    "  --------------------------------------------------  ",
    "    1. Space e         Open file tree                  ",
    "    2. Navigate + Enter to open a file                 ",
    "    3. i to edit, Ctrl+s to save                       ",
    "    4. Space gg        Review changes in lazygit       ",
    "    5. Ctrl+h          Jump to Claude pane             ",
    "    6. Ctrl+l          Jump back to editor             ",
    "                                                      ",
    "  Press q or Esc to close this window                  ",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = 56
  local height = math.min(#lines, vim.o.lines - 4)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "single",
    title = " DEV IDE MANUAL ",
    title_pos = "center",
  })

  -- Close with q or Esc
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf })
end, { desc = "Open IDE manual" })

-- ── VS Code-friendly save/close keymaps ───────────────────
-- Ctrl+s to save (works in normal and insert mode)
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
-- Space w to save
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
-- Space x to close buffer (NOT neovim — just closes the tab/file)
vim.keymap.set("n", "<leader>x", "<cmd>bd<cr>", { desc = "Close buffer" })
-- Space q to quit neovim (only when you actually want to exit)
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit neovim" })

-- ── Extra keymaps ─────────────────────────────────────────
-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Better window navigation (fallback if not in tmux)
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Move lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Stay centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
