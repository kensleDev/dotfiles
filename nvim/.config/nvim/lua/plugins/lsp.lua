local function get_typescript_sdk()
  local tsc_path = vim.fn.exepath("tsc")
  if tsc_path == "" then
    return nil
  end
  return vim.fn.fnamemodify(tsc_path, ":h:h") .. "/lib/node_modules/typescript/lib"
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {
          init_options = {
            typescript = {
              tsdk = get_typescript_sdk(),
            },
          },
        },
        vtsls = {
          settings = {
            typescript = {
              tsdk = get_typescript_sdk(),
            },
          },
        },
      },
    },
  },
}
