-- In your lazy plugin specification list
return {
	"carderne/pi-nvim",
	config = function()
		require("pi-nvim").setup({
			-- Options (defaults shown below)
			socket_path = nil, -- auto-discovers running pi sockets
			set_default_keymaps = true,
		})
	end,
}
