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
if not vim.uv.fs_stat(lazypath) then
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

  -- File tree (right side, loads on first use)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle position=right<cr>", desc = "Toggle file tree" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in tree" },
    },
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
          use_libuv_file_watcher = true,
        },
      })
    end,
  },

  -- Fuzzy finder (loads on first keypress)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search file contents" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>f.", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
          path_display = { "truncate" },
          layout_config = {
            horizontal = { preview_width = 0.5 },
          },
        },
      })
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- Treesitter (parser installer; highlighting is built into nvim 0.11+)
  -- Install parsers manually: :TSInstall python lua etc.
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
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
        { "<leader>cl", desc = "Claude dashboard (clorch)" },
        { "<leader>h", group = "Hunk" },
        { "<leader>m", group = "Markdown" },
      })
    end,
  },

  -- Git signs in gutter + inline blame
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
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

  -- Buffer tab bar (shows open files at top)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "neo-tree", text = "Files", highlight = "Directory", separator = true },
          },
          show_buffer_close_icons = false,
          show_close_icon = false,
          separator_style = "thin",
          always_show_bufferline = true,
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
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
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
          { name = "buffer", keyword_length = 3 },
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
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Surround text objects
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- AI code completion (Codeium — free inline suggestions)
  {
    "Exafunction/codeium.vim",
    event = "InsertEnter",
    config = function()
      vim.g.codeium_disable_bindings = 1
      -- Accept: Ctrl+y
      vim.keymap.set("i", "<C-y>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true, desc = "Accept Codeium suggestion" })
      -- Cycle: Ctrl+j (next) / Ctrl+k (prev)
      vim.keymap.set("i", "<C-j>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true, silent = true, desc = "Next Codeium suggestion" })
      vim.keymap.set("i", "<C-k>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true, silent = true, desc = "Prev Codeium suggestion" })
      -- Dismiss: Ctrl+e
      vim.keymap.set("i", "<C-e>", function() return vim.fn["codeium#Clear"]() end, { expr = true, silent = true, desc = "Dismiss Codeium suggestion" })
      -- Toggle: Space ct
      vim.keymap.set("n", "<leader>ct", function()
        if vim.g.codeium_enabled == nil or vim.g.codeium_enabled == true then
          vim.cmd("Codeium Disable")
          vim.g.codeium_enabled = false
          vim.notify("Codeium disabled", vim.log.levels.INFO)
        else
          vim.cmd("Codeium Enable")
          vim.g.codeium_enabled = true
          vim.notify("Codeium enabled", vim.log.levels.INFO)
        end
      end, { desc = "Toggle Codeium AI completion" })
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
}, {
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },
})

-- ── Python settings (PEP 8: 4-space indentation) ─────────
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true
    vim.bo.textwidth = 88
  end,
})

-- ── LSP (native vim.lsp.config, nvim 0.11+) ──────────────
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

-- Python LSP: pyright (type checking + completions)
vim.lsp.config("pyright", {
  on_init = function(client)
    -- Auto-detect virtualenv per project root
    local root = client.root_dir or vim.fn.getcwd()
    if vim.env.VIRTUAL_ENV then
      client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
        python = { pythonPath = vim.env.VIRTUAL_ENV .. "/bin/python" },
      })
      return
    end
    for _, dir in ipairs({ ".venv", "venv" }) do
      local path = root .. "/" .. dir .. "/bin/python"
      if vim.fn.executable(path) == 1 then
        client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
          python = { pythonPath = path },
        })
        return
      end
    end
  end,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = false,  -- Reduce memory: don't search for all packages
        useLibraryCodeForTypes = false,  -- Reduce memory: don't analyze library code
        diagnosticMode = "openFilesOnly",  -- Reduce memory: only check open files, not entire workspace
        autoImportCompletions = true,
      },
    },
  },
})

-- Python LSP: ruff (fast linting + formatting, replaces black/isort/flake8)
vim.lsp.config("ruff", {
  init_options = {
    settings = {
      organizeImports = true,
      fixAll = true,
    },
  },
})

-- TypeScript/JavaScript LSP
vim.lsp.config("ts_ls", {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
  },
})

vim.lsp.enable({ "pyright", "ruff", "lua_ls", "ts_ls" })

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
    vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, opts)
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
    -- Inlay hints (show type hints inline for Python)
    if vim.lsp.inlay_hint then
      vim.keymap.set("n", "<leader>ch", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, { buffer = ev.buf, desc = "Toggle inlay hints" })
    end
    -- Disable ruff hover in favor of pyright
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
})

-- Format Python on save (via ruff)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({ async = false })
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

-- ── Clorch (Claude session dashboard) ─────────────────────
vim.keymap.set("n", "<leader>cl", function()
  vim.fn.system("tmux new-window -n clorch clorch")
end, { desc = "Open clorch Claude dashboard" })

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
    "    Space fr           Recent files                    ",
    "    Space fs           Document symbols (functions)    ",
    "    Space fS           Workspace symbols               ",
    "    Space f.           Resume last search              ",
    "                                                      ",
    "  BUFFERS (open files shown in tab bar)               ",
    "  --------------------------------------------------  ",
    "    Shift+L            Next buffer (tab)               ",
    "    Shift+H            Previous buffer (tab)           ",
    "    Space x            Close current buffer            ",
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
    "    Space ca           Code action (quick fix/import)  ",
    "    Space rn           Rename symbol                   ",
    "    Space cf           Format file                     ",
    "    Space d            Show diagnostic details         ",
    "    ] d / [ d          Next / prev diagnostic          ",
    "    Space ch           Toggle inlay type hints         ",
    "                                                      ",
    "  CLAUDE SESSIONS (clorch dashboard)                 ",
    "  --------------------------------------------------  ",
    "    Ctrl+a b           Toggle clorch window (bright)  ",
    "    Space cl           Jump to clorch from neovim     ",
    "                                                      ",
    "  Inside Clorch:                                      ",
    "    q / Esc            Close dashboard                ",
    "    j/k or ↑/↓         Navigate agents                ",
    "    y / n              Approve / Deny request         ",
    "    s                  Toggle sound                   ",
    "    t                  Jump to agent's tmux window    ",
    "    ?                  Show clorch help               ",
    "                                                      ",
    "  AI COMPLETION (Codeium — inline suggestions)        ",
    "  --------------------------------------------------  ",
    "    Ctrl+y             Accept suggestion               ",
    "    Ctrl+j             Next suggestion                  ",
    "    Ctrl+k             Previous suggestion              ",
    "    Ctrl+e             Dismiss suggestion               ",
    "    Space ct           Toggle Codeium on/off            ",
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
    "    V then Tab/S-Tab   Indent/dedent selection          ",
    "    Ctrl+d / Ctrl+u    Half-page scroll                ",
    "    gcc                Toggle line comment             ",
    "    gc (visual)        Toggle comment on selection     ",
    "    Tab / S-Tab        Next/prev autocomplete item     ",
    "    ys<motion><char>   Surround with char (e.g. ysiw\") ",
    "    ds<char>           Delete surrounding char         ",
    "    cs<old><new>       Change surrounding char         ",
    "                                                      ",
    "  PYTHON                                              ",
    "  --------------------------------------------------  ",
    "    Auto-format on save (ruff)                         ",
    "    Auto-import via Space ca (code action)             ",
    "    4-space indentation (PEP 8)                        ",
    "                                                      ",
    "  MARKDOWN (in .md files)                             ",
    "  --------------------------------------------------  ",
    "    Space mp           Toggle markdown preview         ",
    "                                                      ",
    "  TIP: Don't use :wq  -- it exits neovim!             ",
    "  Use Ctrl+s to save, Space x to close a file.        ",
    "                                                      ",
    "  QUICK START                                         ",
    "  --------------------------------------------------  ",
    "    1. Space ff        Find and open a file            ",
    "    2. i to edit, Ctrl+s to save                       ",
    "    3. Shift+L / Shift+H to switch open files          ",
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
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>x", "<cmd>bd!<cr>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit neovim" })

-- ── Extra keymaps ─────────────────────────────────────────
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Buffer navigation (Shift+H/L to switch tabs)
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })

-- Move lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Indent/dedent in visual mode with Tab/Shift-Tab (keeps selection)
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent selection" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Dedent selection" })

-- Stay centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
