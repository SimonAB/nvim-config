-- Configuration for vimtex
-- LaTeX editing support with enhanced features

-- Detect platform and set appropriate PDF viewer
local is_macos = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
local is_linux = vim.fn.has("unix") == 1 and vim.fn.has("macunix") == 0

-- VimTeX configuration (vim variables)
if is_macos then
	-- macOS: Use Skim for PDF viewing
	vim.g.vimtex_view_method = "skim"
	vim.g.vimtex_view_general_viewer = "skim"
	vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
elseif is_linux then
	-- Linux: Use Zathura for PDF viewing
	vim.g.vimtex_view_method = "zathura"
	vim.g.vimtex_view_general_viewer = "zathura"
	vim.g.vimtex_view_general_options = "--synctex-forward %line:0:%tex %pdf"
else
	-- Fallback: generic viewer
	vim.g.vimtex_view_method = "general"
	vim.g.vimtex_view_general_viewer = "zathura"
	vim.g.vimtex_view_general_options = "--synctex-forward %line:0:%tex %pdf"
end

vim.g.vimtex_compiler_method = "latexmk" -- Use latexmk for compilation
vim.g.vimtex_compiler_latexmk = {
	build_dir = "build",
	options = {
		"-pdf",
		"-pdflatex=lualatex",
		"-interaction=nonstopmode",
		"-synctex=1",
		"-file-line-error",
	},
}

-- Disable spell checking in citation arguments
-- This must be set before VimTeX initialises to take effect
vim.g.vimtex_syntax_custom_cmds = {
  { name = 'cite', argspell = false },
  { name = 'supercite', argspell = false },
  { name = 'citep', argspell = false },
  { name = 'citet', argspell = false },
  { name = 'citealp', argspell = false },
  { name = 'citealt', argspell = false },
  { name = 'citeauthor', argspell = false },
  { name = 'citeyear', argspell = false },
  { name = 'parencite', argspell = false },
  { name = 'footcite', argspell = false },
  { name = 'textcite', argspell = false },
  { name = 'autocite', argspell = false },
}

-- Additional VimTeX syntax configuration for better spell checking
vim.g.vimtex_syntax_nospell_commands = {
  'cite', 'citep', 'citet', 'citealp', 'citealt', 'citeauthor', 'citeyear',
  'parencite', 'footcite', 'textcite', 'autocite', 'supercite'
}

-- Function to apply citation spell exclusion rules
local function apply_citation_nospell_rules()
  -- Only apply if we're in a tex file
  if vim.bo.filetype ~= 'tex' then return end

  -- Clear any existing citation syntax rules first
  pcall(vim.cmd, 'syntax clear texCiteArg')
  pcall(vim.cmd, 'syntax clear texCiteNoSpell')

  -- Use higher priority syntax rules with @NoSpell cluster
  -- The 'contained' keyword prevents conflicts with existing VimTeX syntax
  pcall(vim.cmd, [[syntax cluster NoSpell add=texCiteNoSpell]])

  -- Define comprehensive syntax matches with high priority
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\cite{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\supercite{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\citep{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\citet{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\citealp{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\citealt{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\citeauthor{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\citeyear{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\parencite{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\footcite{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\textcite{[^}]*}" contains=@NoSpell contained containedin=ALL]])
  pcall(vim.cmd, [[syntax match texCiteNoSpell "\\autocite{[^}]*}" contains=@NoSpell contained containedin=ALL]])

  -- Alternative approach: directly modify spell checking regions
  -- This creates regions that are explicitly excluded from spell checking
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\cite{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\supercite{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\citep{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\citet{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\citealp{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\citealt{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\citeauthor{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\citeyear{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\parencite{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\footcite{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\textcite{" end="}" oneline contains=@NoSpell]])
  pcall(vim.cmd, [[syntax region texCiteRegion start="\\autocite{" end="}" oneline contains=@NoSpell]])

  -- Force syntax highlighting refresh with higher priority
  pcall(vim.cmd, 'syntax sync fromstart')
  pcall(vim.cmd, 'redraw!')

  print("Citation spell exclusion rules applied")
end

-- Complete spell exclusion using @NoSpell syntax groups
-- This prevents both highlighting AND navigation (]s/[s) from detecting citation arguments
local citation_spell_group = vim.api.nvim_create_augroup('VimTeXCitationSpell', { clear = true })

-- Apply rules on multiple events to ensure they're always active
vim.api.nvim_create_autocmd({"FileType", "BufEnter", "BufReadPost", "Syntax"}, {
  group = citation_spell_group,
  pattern = "tex",
  desc = "Configure LaTeX citation spell exclusion",
  callback = function()
    -- Apply rules immediately
    apply_citation_nospell_rules()

    -- Also apply after a delay to handle VimTeX initialization
    vim.defer_fn(apply_citation_nospell_rules, 100)
    vim.defer_fn(apply_citation_nospell_rules, 300)
  end,
})

-- Create manual command to reapply citation spell rules
vim.api.nvim_create_user_command('VimTexFixCitationSpell', apply_citation_nospell_rules, {
  desc = "Manually apply citation spell exclusion rules"
})

-- Auto-apply when VimTeX state changes
vim.api.nvim_create_autocmd("User", {
  group = citation_spell_group,
  pattern = "VimtexEventInitPost",
  desc = "Apply citation spell rules after VimTeX initialization",
  callback = function()
    vim.defer_fn(apply_citation_nospell_rules, 50)
  end,
})
