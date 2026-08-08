#!/bin/bash
# Generate test files of various sizes for benchmarking

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
TEST_FILES_DIR="$CONFIG_DIR/.test-files"

mkdir -p "$TEST_FILES_DIR"

echo "Generating test files in $TEST_FILES_DIR..."

# Small Lua file (~100 lines, ~3KB)
echo "Generating small.lua (~100 lines)..."
cat > "$TEST_FILES_DIR/small.lua" << 'EOF'
-- Small Lua Configuration File
-- Used for benchmarking Neovim performance

local M = {}

M.options = {
    tabstop = 2,
    shiftwidth = 2,
    expandtab = true,
    number = true,
    relativenumber = true,
    wrap = false,
}

function M.setup(opts)
    opts = opts or {}
    for key, value in pairs(opts) do
        M.options[key] = value
    end
    
    for key, value in pairs(M.options) do
        vim.opt[key] = value
    end
end

function M.get_option(key)
    return M.options[key]
end

function M.set_option(key, value)
    M.options[key] = value
    vim.opt[key] = value
end

local keymaps = {
    { "n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" } },
    { "n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" } },
    { "n", "<leader>e", "<cmd>Ex<cr>", { desc = "Explorer" } },
    { "n", "<C-h>", "<C-w>h", { desc = "Go to left window" } },
    { "n", "<C-j>", "<C-w>j", { desc = "Go to lower window" } },
    { "n", "<C-k>", "<C-w>k", { desc = "Go to upper window" } },
    { "n", "<C-l>", "<C-w>l", { desc = "Go to right window" } },
}

for _, map in ipairs(keymaps) do
    vim.keymap.set(unpack(map))
end

local autocmds = {
    { "BufWritePre", "*.lua", "lua vim.lsp.buf.format()" },
    { "BufReadPost", "*", 'lua vim.cmd("normal! g`\"")' },
    { "TextYankPost", "*", 'silent! lua vim.highlight.on_yank()' },
}

for _, au in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(au[1], {
        pattern = au[2],
        command = au[3],
    })
end

return M
EOF

# Medium TypeScript file (~10,000 lines, ~300KB)
echo "Generating medium.ts (~10,000 lines)..."
{
    echo "// Generated TypeScript file for benchmarking"
    echo "// Size: ~10,000 lines"
    echo ""
    
    echo "interface User {"
    echo "  id: number;"
    echo "  name: string;"
    echo "  email: string;"
    echo "  createdAt: Date;"
    echo "  updatedAt: Date;"
    echo "}"
    echo ""
    
    echo "interface Product {"
    echo "  id: number;"
    echo "  name: string;"
    echo "  price: number;"
    echo "  description: string;"
    echo "  category: string;"
    echo "  inStock: boolean;"
    echo "}"
    echo ""
    
    echo "class DataService {"
    echo "  private cache: Map<string, unknown>;"
    echo "  private apiUrl: string;"
    echo ""
    echo "  constructor(apiUrl: string) {"
    echo "    this.apiUrl = apiUrl;"
    echo "    this.cache = new Map();"
    echo "  }"
    echo ""
    
    for i in $(seq 1 200); do
        cat << FUNCTION
  async function${i}(): Promise<User> {
    const response = await fetch(\`\${this.apiUrl}/users/${i}\`);
    if (!response.ok) {
      throw new Error(\`Failed to fetch user ${i}\`);
    }
    return response.json();
  }

  async function${i}WithCache(): Promise<User> {
    const cacheKey = \`user_${i}\`;
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey) as User;
    }
    const data = await this.function${i}();
    this.cache.set(cacheKey, data);
    return data;
  }

  async function${i}Product(): Promise<Product> {
    const response = await fetch(\`\${this.apiUrl}/products/${i}\`);
    if (!response.ok) {
      throw new Error(\`Failed to fetch product ${i}\`);
    }
    return response.json();
  }

  async function${i}ProductWithCache(): Promise<Product> {
    const cacheKey = \`product_${i}\`;
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey) as Product;
    }
    const data = await this.function${i}Product();
    this.cache.set(cacheKey, data);
    return data;
  }

FUNCTION
    done
    
    echo "}"
    echo ""
    echo "export { DataService };"
    echo "export type { User, Product };"
} > "$TEST_FILES_DIR/medium.ts"

# Large JSON file (~2MB)
echo "Generating large.json (~2MB)..."
{
    echo "["
    
    total_size=0
    target_size=$((2 * 1024 * 1024))
    item=0
    
    while [[ $total_size -lt $target_size ]]; do
        if [[ $item -gt 0 ]]; then
            echo ","
        fi
        
        json_line=$(cat << JSON
  {
    "id": $item,
    "name": "User $item",
    "email": "user$item@example.com",
    "address": {
      "street": "$((item * 100)) Main Street",
      "city": "Springfield",
      "state": "IL",
      "zip": "$((62700 + (item % 1000)))"
    },
    "phone": "555-$((item % 10000))",
    "company": "Acme Corp",
    "title": "Software Engineer $((item % 10))",
    "skills": ["JavaScript", "TypeScript", "React", "Node.js", "Python"],
    "projects": [
      {"name": "Project Alpha", "status": "active"},
      {"name": "Project Beta", "status": "completed"},
      {"name": "Project Gamma", "status": "pending"}
    ],
    "metadata": {
      "created": "2024-01-$((1 + (item % 28)))",
      "updated": "2024-02-$((1 + (item % 28)))",
      "version": "$((item % 100)).$((item % 10)).0"
    }
  }
JSON
)
        echo "$json_line"
        total_size=$((total_size + ${#json_line}))
        item=$((item + 1))
    done
    
    echo ""
    echo "]"
} > "$TEST_FILES_DIR/large.json"

# Large log file (~2MB)
echo "Generating large.log (~2MB)..."
{
    total_size=0
    target_size=$((2 * 1024 * 1024))
    line_num=0
    
    levels=("INFO" "DEBUG" "WARN" "ERROR" "TRACE")
    services=("auth-service" "user-service" "product-service" "order-service" "payment-service" "notification-service" "cache-service" "api-gateway")
    
    while [[ $total_size -lt $target_size ]]; do
        level=${levels[$((line_num % 5))]}
        service=${services[$((line_num % 8))]}
        timestamp=$(date -d "@$((1700000000 + line_num))" '+%Y-%m-%d %H:%M:%S.%3N')
        
        echo "[$timestamp] [$level] [$service] Request processed successfully for user_$((line_num % 10000)) - request_id=abc${line_num}def - duration=$((line_num % 1000))ms - status=200 - ip=192.168.$((line_num % 256)).$((line_num % 256))"
        
        total_size=$((total_size + 200))
        line_num=$((line_num + 1))
    done
} > "$TEST_FILES_DIR/large.log"

echo ""
echo "Test files generated:"
ls -lh "$TEST_FILES_DIR"
echo ""
echo "File sizes:"
du -sh "$TEST_FILES_DIR"/*
