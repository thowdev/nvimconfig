----------------------------------------------------------------------------------------------------
-- SETUP & DEPENDENCIES
----------------------------------------------------------------------------------------------------

-- Ensure fzf-lua is installed
local has_fzf, fzf = pcall(require, "fzf-lua")
if not has_fzf then
  vim.notify(" Error: fzf-lua is missing!", vim.log.levels.ERROR)
  return
end

-- Add default zettelkasten directory to path. Explicitly ensure manually its existence
local zettel_root = vim.fn.expand("~/Documents/zettelkasten")

if vim.fn.isdirectory(zettel_root) == 0 then
  local errmsg = string.format("Error: Path '%s' not found.", zettel_root)
  vim.notify(errmsg, vim.log.levels.ERROR)
  return
end

vim.opt.path:append(zettel_root)

-- Add default subfolders in zettel_root
local zettel_folders = {
  "00_inbox",
  "10_dailies",
  "20_ibm",
  "30_private",
  "40_projects",
  "50_knowledge",
  "90_assets",
  "99_archive",
  ".templates"
}

for _, folder_name in ipairs(zettel_folders) do
  local full_path = zettel_root .. "/" .. folder_name

  if vim.fn.isdirectory(full_path) == 0 then
    vim.fn.mkdir(full_path, "p")
  end

  vim.opt.path:append(full_path)
end

-- Set useful variables and paths
local daily_path = zettel_root .. "/10_dailies"
-- Recursive path for 10_dailies because the contain folders for the years
vim.opt.path:append(daily_path)

----------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------------------------------------

-- Get the current filename without the extension (and without the path)
local function get_current_zettel()
  return vim.fn.expand("%:t:r")
end

-- Get the current filename without the extension (and without the path)
local function get_frontmatter_title(filepath)
  local f = io.open(filepath, "r")
  if not f then return nil end

  local title = nil
  local first_line = true
  for line in f:lines() do
    local match = line:match("^%s*title:%s*[\"']?(.-)[\"']?%s*$")
    if match then title = match; break end
    if line:match("^%s*---%s*$") then
      if first_line then first_line = false else break end
    end
  end
  f:close()
  return title
end

-- Collect current rg default opts, set extra_args and ensure -e at the end of all args
local function get_rg_opts(extra_args)
  local defaults = fzf.config.defaults.grep.rg_opts
  local clean_defaults = defaults:gsub("%-e$", "")
  return clean_defaults .. " " .. extra_args .. " -e"
end

-- Check if current/new zettel has backlink to its caller "prev_zettel"
local function check_backlink(prev_zettel)
  if not prev_zettel or prev_zettel == "" then return end

  local escaped_id = prev_zettel:gsub("([^%w])", "%%%1")
  local pattern = "%[%[" .. escaped_id .. "[%]|]"
  vim.defer_fn(function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(lines) do
      if line:find(pattern) then return end -- Gefunden, alles gut
    end
    vim.notify("No backlink to [[" .. prev_zettel .. "]]!", vim.log.levels.WARN)
  end, 150)
end

-- Get date of the last daily zettel
local function get_last_daily_date(current_date_iso)
  local pattern = daily_path .. "/20*.md"
  local files = vim.fn.glob(pattern, false, true)

  if #files == 0 then return nil end

  -- Sort from oldest to newest
  table.sort(files)

  local last_found = nil

  for _, filepath in ipairs(files) do
    local filename_date = vim.fn.fnamemodify(filepath, ":t:r")

    if filename_date:match("^%d%d%d%d%-%d%d%-%d%d$") then
      if filename_date < current_date_iso then
        last_found = filename_date
      else
        break
      end
    end
  end

  return last_found
end

----------------------------------------------------------------------------------------------------
-- CORE LOGIC
----------------------------------------------------------------------------------------------------
local function create_zettel(mode, zettel_title)
  local id = os.date("%Y%m%d%H%M")
  local year = os.date("%Y")
  local date_iso = os.date("%Y-%m-%d")


  local filename
  local folder
  local title = zettel_title
  local nav_header = ""

  if mode == "daily" then
    filename = date_iso .. ".md"
    title = "Daily " .. date_iso
    folder = "10_dailies"

    local now = os.time()
    local tomorrow_iso = os.date("%Y-%m-%d", now + (24 * 60 * 60))

    local prev_date = get_last_daily_date(date_iso)
    if not prev_date then
        prev_date = os.date("%Y-%m-%d", now - (24 * 60 * 60))
    end

    nav_header = string.format("<< [[%s|Prev]] | [[%s|Next]] >>", prev_date, tomorrow_iso)

  else
    if not title or not title:match("%S") then
      vim.notify("ERROR: No title or empty title!", vim.log.levels.ERROR)
      return
    end
    local clean_title = title:gsub("%s+", "-"):lower()
    filename = clean_title .. "-" .. id .. ".md"
    folder = "00_inbox"
  end

  local base_path = zettel_root .. "/" .. folder .. "/"
  local full_path = base_path .. filename
  if vim.fn.isdirectory(base_path) == 0 then
    vim.fn.mkdir(base_path, "p")
  end

  local file_exists = vim.fn.filereadable(full_path) == 1
  vim.cmd.edit(full_path)

  if not file_exists then
    local header = {
                    "---",
                    "title: " .. title,
                    "date: " .. date_iso,
                    "id: " .. id,
                    "tags: [" .. mode .. "]",
                    "---",
                    "",
                    "# " .. title,
                    "",
                    nav_header, (mode == "daily" and "" or ""),
                    "## Notes",
                    "",
                    "---",
                    "## Footer",
                    "### Links",
                    "### Abbreviations",
                    "### Auto backlinks",
                    "",
                    "- [[ " .. (mode == "daily" and "Index" or date_iso) .. " ]]",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
    vim.cmd("normal! G")
    vim.cmd("write")
    print("Created in: " .. folder)
  else
    print("File already exists.")
  end
end

-- Commands
vim.api.nvim_create_user_command('ZN', function(opts) create_zettel("zettel", opts.args) end, { nargs = 1, force=true })
vim.api.nvim_create_user_command('ZD', function() create_zettel("daily", "") end, { nargs = 0, force=true })

-- Keymaps für Erstellung
vim.keymap.set("n", "<leader>zn", ":ZN ", { desc = "New Zettel" })
vim.keymap.set("n", "<leader>zd", "<cmd>ZD<cr>", { desc = "Daily Journal" })

----------------------------------------------------------------------------------------------------
--- 4. NAVIGATION (ENTER KEY)
----------------------------------------------------------------------------------------------------
vim.keymap.set("n", "<CR>", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local prev_zettel = get_current_zettel()

  -- Wiki Link Check [[...]]
  local before = line:sub(1, col):match(".*%[%[(.*)$") or ""
  local after = line:sub(col + 1):match("^(.-)%]%].*") or ""
  local full_link = before .. after

  if full_link ~= "" then
    vim.cmd("silent! write")
    local target = full_link:match("([^|]+)"):gsub("^%s*(.-)%s*$", "%1")
    local is_asset = target:match("^asset:")
    local clean_target = target:gsub("^asset:", "")

    -- Asset logic
    if is_asset or (clean_target:match("%.%w+$") and not clean_target:match("%.md$")) then
      local find_cmd = "find " .. zettel_root .. "/90_assets -name '" .. clean_target .. "' | head -n 1"
      local asset_path = vim.fn.system(find_cmd):gsub("\n", "")
      if asset_path ~= "" then
        local opener = jit.os == "OSX" and "open" or "xdg-open"
        vim.fn.jobstart({ opener, asset_path }, { detach = true })
      else
        vim.notify("Asset not found", vim.log.levels.ERROR)
      end
      return
    end

    -- Zettel Jump Logic
    local filename = target
    if not filename:match("%.md$") then filename = filename .. ".md" end

    local function scan_recursive(dir, search_file)
      -- Kompatibilität: vim.uv (neu) oder vim.loop (alt)
      local uv = vim.uv or vim.loop
      local scanner = uv.fs_scandir(dir)
      if not scanner then return nil end

      while true do
        local name, type = uv.fs_scandir_next(scanner)
        if not name then break end -- Verzeichnis fertig

        local full_path = dir .. "/" .. name

        if type == "directory" then
          -- BLOCKLISTE: Hier Ordner ausschließen!
          if name ~= "90_assets"
            and name ~= ".git" then

            -- Rekursiv absteigen (ruft sich selbst auf)
            local found = scan_recursive(full_path, search_file)
            if found then return found end
          end
        elseif type == "file" and name == search_file then
          return full_path -- Treffer!
        end
      end
    end


    local found_path_result = scan_recursive(zettel_root, filename)
    local found_path = found_path_result or ""

    if found_path ~= "" then
      vim.cmd("edit " .. found_path)
      check_backlink(prev_zettel)
    else
      -- Create missing Zettel in Inbox
      local id = os.date("%Y%m%d%H%M")
      local inbox_path = zettel_root .. "/00_inbox/"
      if vim.fn.isdirectory(inbox_path) == 0 then vim.fn.mkdir(inbox_path, "p") end

      local new_file = inbox_path .. target .. "-" .. id .. ".md"
      vim.cmd("edit " .. new_file)

      local header = {
                      "---",
                      "title: " .. target,
                      "date: " .. os.date("%Y-%m-%d"),
                      "id: " .. id,
                      "tags: [inbox]",
                      "---",
                      "",
                      "# " .. target,
                      "",
                      "",
                      "---",
                      "## Footer",
                      "",
                      "### Links",
                      "",
                      "### Definitionen",
                      "",
                      "### Auto backlinks",
                      "- [[" .. prev_zettel .. "]]",
      }
      vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
      vim.cmd("write")
      print("Create new zettel in inbox")
    end
    return
  end

  -- URL Check
  local url = line:match("https?://[%w%-_%.%?%&%=%/]+")
  if url then
    local opener = jit.os == "OSX" and "open" or "xdg-open"
    os.execute(opener .. " '" .. url .. "'")
    return
  end


  -- Default Enter
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
end, { desc = "Smart Enter" })

----------------------------------------------------------------------------------------------------
-- SEARCH & TOOLS
----------------------------------------------------------------------------------------------------
local function search_zettel_root()
  fzf.live_grep({
    cwd = zettel_root,
    prompt = zettel_root .. " > ",
    rg_opts = get_rg_opts("-g '!90_assets'"),
    multiline = true
  })
end

vim.keymap.set("n", "<leader>fg", search_zettel_root, { desc = "Grep Zettelkasten" })
vim.keymap.set("n", "<leader>zg", "<cmd>FzfLua live_grep<cr>")
vim.keymap.set("n", "<leader>zz", function() fzf.files({ cwd = zettel_root }) end)

-- Link Inserter (incl. archive, excl. assets folder)
vim.keymap.set("n", "<leader>zl", function()
  local search_dirs = {}

  for _, folder in ipairs(zettel_folders) do
    if folder ~= ".templates" and folder ~= "90_assets" then
      table.insert(search_dirs, folder)
    end
  end
  local folders_str = table.concat(search_dirs, " ")

  fzf.files({
    cwd = zettel_root,
    cmd = "fd . " .. folders_str .. " --type f",
    prompt = "Link Note> ",
    file_icons = false,
    git_icons = false,
    actions = {
      ["default"] = function(sel)
        if not sel or #sel == 0 then
          vim.notify("Keine Auswahl getroffen!", vim.log.levels.WARN)
          return
        end

        local raw_file = sel[1]
        local file = raw_file:match("[^\t]+") or raw_file
        file = vim.trim(file)
        local name = vim.fn.fnamemodify(file, ":t:r")
        local link = "[[" .. name .. "]]"

        vim.schedule(function()
          if link and link ~= "" then
            vim.api.nvim_put({ link }, "c", true, true)
          else
            vim.notify("Error: Link variable is empty!", vim.log.levels.ERROR)
          end
        end)
      end
    },
    winopts = { width = 0.8, title = "Link Note" }
  })
end, {desc = "Insert Note Link"})

-- Backlinks & MOC Generators (funktionieren auch ohne FZF)
vim.keymap.set("n", "<leader>zm", function()
  vim.ui.input({ prompt = "Tag (ohne #): " }, function(tag)
    if not tag or tag == "" then return end
    local handle = io.popen("rg -l '(tags:.*" .. tag .. "|#" .. tag .. ")'")
    local res = handle:read("*a"); handle:close()
    local links = { "## MOC: #" .. tag, "" }
    for path in res:gmatch("[^\r\n]+") do
        local id = path:gsub(".*/", ""):gsub("%.md$", "")
        table.insert(links, "- [[" .. id .. "|" .. (get_frontmatter_title(path) or id) .. "]]")
    end
    local r = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, r, r, false, links)
  end)
end)


---#################################################################################################
---# Keymaps
---#################################################################################################

vim.keymap.set("n", "<leader>zi", function()

  vim.cmd("write")

  local zettel = get_current_zettel()
  local regex = "\\[\\[" .. zettel .. "([\\|#\\]])"
  local cmd = "rg -l '" .. regex .. "' " .. vim.fn.shellescape(zettel_root)

  local handle = io.popen(cmd)
  local res = handle:read("*a")
  handle:close()

  local new_lines = { "### Auto backlinks", "" }
  local has_results = false

  for path in res:gmatch("[^\r\n]+") do
    local id = vim.fn.fnamemodify(path, ":t:r")

    if id ~= zettel then
      local title = get_frontmatter_title(path) or id
      table.insert(new_lines, "- [[" .. id .. "|" .. title .. "]]")
      has_results = true
    end
  end

  if not has_results then
    table.insert(new_lines, "- (No backlinks found)")
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local header_row = -1

  for i, line in ipairs(lines) do
    if line:match("^### Auto backlinks") then
      header_row = i - 1
      break
    end
  end

  if header_row ~= -1 then
    vim.api.nvim_buf_set_lines(0, header_row, -1, false, new_lines)
  else
    local footer = { "", "---", unpack(new_lines) }
    vim.api.nvim_buf_set_lines(0, -1, -1, false, footer)
  end
  print("Backlinks aktualisiert (" .. (#new_lines - 2) .. " gefunden).")

end)

print(">>> Zettelkasten Config geladen. <<<")
