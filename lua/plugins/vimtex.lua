-- Configuration for vimtex
-- LaTeX editing support with enhanced features

-- VimTeX configuration (vim variables)
vim.g.vimtex_view_method = "skim" -- Use Skim for PDF viewing
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
vim.g.vimtex_view_general_viewer = "skim"
vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
